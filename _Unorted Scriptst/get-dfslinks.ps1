<#
    .SYNOPSIS
    Takes one or more UNC formatted DFS namespace paths and returns the names and
    targets of all links contained in that namespace. 
    .DESCRIPTION
    PowerShell wrapper around a C# class which uses .Net native interop for
    calling into Netapi32.dll NetDfsEnum native system call. Which returns
    a List<DFSLink> (list of structs) and is converted to a PowerShell array
    of DFSLink. DFSLink contains 2 members [string]name and [string[]]target.    
    .PARAMETER Path
    string or string[] of namespace UNC path(s)
    .EXAMPLE
    Get-DfsLInks -Path "\\contoso\Namespace01"
    
    name                                             target                                          
    ----                                             ------                                          
    Foo                                              {\\fooserve\Data\Shared}        
    Bar                                              {\\fooserve\Data\boo,\\fooserve\Data\Shared}        
    ...
#>
function Get-Links {
    [OutputType([object[]])]    
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelinebyPropertyName=$True,
                   Position=0)]
        $Path
    )

    Begin {
        $netApiDef = @'
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class DfsTools {
    [DllImport("Netapi32.dll", EntryPoint = "NetApiBufferFree")]
    public static extern uint NetApiBufferFree(IntPtr buffer);

    [DllImport("Netapi32.dll", CharSet = CharSet.Auto/*, SetLastError=true //Return value (NET_API_STATUS) contains error */)]
    public static extern int NetDfsEnum(
        [MarshalAs(UnmanagedType.LPWStr)]string DfsName,
        int Level,
        int PrefMaxLen,
        out IntPtr Buffer,
        [MarshalAs(UnmanagedType.I4)]out int EntriesRead,
        [MarshalAs(UnmanagedType.I4)]ref int ResumeHandle);

    const int MAX_PREFERRED_LENGTH = 0xFFFFFFF;
    const int NERR_Success = 0;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DFS_INFO_3
    {
        [MarshalAs(UnmanagedType.LPWStr)]
        public string EntryPath;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string Comment;
        public UInt32 State;
        public UInt32 NumberOfStorages;
        public IntPtr Storages;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DFS_STORAGE_INFO
    {
        public Int32 State;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string ServerName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string ShareName;
    }

    public struct DFSLink
    {
        public string name;
        public string[] target;
        public DFSLink(string Name, string[] Target) {
            this.name = Name;
            this.target = Target;
        }
    }


    public static List<DFSLink> GetDfsLinks(string sDFSRoot) {
        List<DFSLink> links = new List<DFSLink>();
        IntPtr pBuffer = new IntPtr();
        int entriesRead = 0;
        int resume = 0;

        var iResult = NetDfsEnum(sDFSRoot, 3, MAX_PREFERRED_LENGTH, out pBuffer, out entriesRead, ref resume);
        if (iResult == 0) {

            // Itterate over entries in namespace
            for (int j = 0; j < entriesRead; j++) {

                DFS_INFO_3 oDFSInfo = (DFS_INFO_3)Marshal.PtrToStructure(new IntPtr(pBuffer.ToInt64() + j * Marshal.SizeOf(typeof(DFS_INFO_3))), typeof(DFS_INFO_3));

                if (oDFSInfo.EntryPath == sDFSRoot) {   // skip link for namespace
                    continue;
                }

                if (!Convert.ToBoolean(oDFSInfo.State & 0x00000001)) {
                    continue;
                }
                
                List<string> targets = new List<string>();

                for (int i = 0; i < oDFSInfo.NumberOfStorages; i++) {   // get targets for link

                    IntPtr pStorage = new IntPtr(oDFSInfo.Storages.ToInt64() + i * Marshal.SizeOf(
                        typeof(DFS_STORAGE_INFO)));

                    DFS_STORAGE_INFO oStorageInfo = (DFS_STORAGE_INFO)Marshal.PtrToStructure(pStorage,
                        typeof(DFS_STORAGE_INFO));

                    //Get Only Active Hosts
                    if (oStorageInfo.State == 2) {
                        targets.Add(@"\\" + oStorageInfo.ServerName + @"\" + oStorageInfo.ShareName );
                    }
                }
                string name = oDFSInfo.EntryPath.Replace(sDFSRoot, "");
                if (name.StartsWith("\\")) {
                    name = name.Substring(1);
                }

                links.Add(new DFSLink(name, targets.ToArray()));    // Collect link info in a nice way
            }
        }
        NetApiBufferFree(pBuffer);
        return links;
    }
}
'@
        $netapi = Add-Type -TypeDefinition $netApiDef -Language CSharp -PassThru

        $returnObj = @()
    }

    Process {
        
        switch ($Path.GetType()) {
            String {                
                try {
                    $returnObj += ([DfsTools]::GetDfsLinks($Path)).ToArray()
                }
                catch {
                    throw
                }
            }
            String[] {
                try {
                    $returnObj += $Path | % { ([DfsTools]::GetDfsLinks($_)).ToArray() }
                }
                catch {
                    throw
                }
            }
        }
    }

    End {
        return $returnObj
    }
}