using System;
using System.DirectoryServices.AccountManagement;
using System.Linq;

namespace ADUserLibrary
{
    public class ADUser
    {
        public string City { get; set; }
        public string FullName { get; set; }
        public string Company { get; set; }
        public string Country { get; set; }
        public string Department { get; set; }
        public string Description { get; set; }
        public string EmailAddress { get; set; }
        public string EmployeeID { get; set; }
        public string OfficePhone { get; set; }
        public string SamAccountName { get; set; }
        public string LastName { get; set; }
        public string Title { get; set; }
        public string ObjectGuid { get; set; }
        public string Firstname { get; set; }
        public string HomeDirectory { get; set; }
        public string Manager { get; set; }
        public string[] MemberOf { get; set; }
        public bool Enabled { get; set; }
        private Logger Logger { get; set; }

        public ADUser(string samAccountName, string logPath = "c:\\temp\\ADUser.log", Logger logger = null)
        {
            if (string.IsNullOrWhiteSpace(samAccountName))
            {
                throw new ArgumentException("SamAccountName cannot be null or empty");
            }

            Logger = logger ?? new Logger(logPath, LogLevel.Info);
            Logger.Info($"Initializing ADUser for {samAccountName}");
            GetAdUser(samAccountName);
        }

        private void GetAdUser(string samAccountName)
        {
            try
            {
                Logger.Info($"Retrieving AD user information for {samAccountName}");
                using (var context = new PrincipalContext(ContextType.Domain))
                {
                    var user = UserPrincipal.FindByIdentity(context, samAccountName);
                    if (user != null)
                    {
                        MapUserProperties(user);
                        Logger.Info($"Successfully retrieved AD user information for {samAccountName}");
                    }
                    else
                    {
                        throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                    }
                }
            }
            catch (Exception ex)
            {
                string errorMessage = $"No ADUser matches the SAMAccountName: {samAccountName}. Error: {ex.Message}";
                Logger.Error(errorMessage);
                throw new Exception(errorMessage);
            }
        }

        private void MapUserProperties(UserPrincipal user)
        {
            City = user.GetUnderlyingObject().GetType().GetProperty("City")?.GetValue(user.GetUnderlyingObject())?.ToString();
            FullName = user.DisplayName;
            Company = user.GetUnderlyingObject().GetType().GetProperty("Company")?.GetValue(user.GetUnderlyingObject())?.ToString();
            Country = user.GetUnderlyingObject().GetType().GetProperty("Country")?.GetValue(user.GetUnderlyingObject())?.ToString();
            Department = user.GetUnderlyingObject().GetType().GetProperty("Department")?.GetValue(user.GetUnderlyingObject())?.ToString();
            Description = user.Description;
            EmailAddress = user.EmailAddress;
            EmployeeID = user.EmployeeId;
            OfficePhone = user.VoiceTelephoneNumber;
            SamAccountName = user.SamAccountName;
            LastName = user.Surname;
            Title = user.GetUnderlyingObject().GetType().GetProperty("Title")?.GetValue(user.GetUnderlyingObject())?.ToString();
            ObjectGuid = user.Guid.ToString();
            Firstname = user.GivenName;
            HomeDirectory = user.HomeDirectory;
            Manager = user.GetUnderlyingObject().GetType().GetProperty("Manager")?.GetValue(user.GetUnderlyingObject())?.ToString();
            MemberOf = user.GetGroups().Select(g => g.Name).ToArray();
            Enabled = user.Enabled ?? false;
            Logger.Info($"Mapped properties for user {SamAccountName}");
        }

        public bool IsSamAccountNameUnique(string samAccountName)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                return user == null;
            }
        }

        public string GenerateRandomPassword()
        {
            const int length = 12;
            const string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();
            var password = new string(Enumerable.Repeat(chars, length).Select(s => s[random.Next(s.Length)]).ToArray());
            return password;
        }

        public void CreateNewUser(string givenName, string surname, string samAccountName, bool enabled)
        {
            if (!IsSamAccountNameUnique(samAccountName))
            {
                throw new Exception($"SamAccountName '{samAccountName}' is already in use");
            }

            string password = GenerateRandomPassword();
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = new UserPrincipal(context)
                {
                    GivenName = givenName,
                    Surname = surname,
                    SamAccountName = samAccountName,
                    Name = $"{givenName} {surname}",
                    UserPrincipalName = $"{samAccountName}@yourdomain.com",
                    Enabled = enabled,
                    PasswordNeverExpires = true
                };
                user.SetPassword(password);
                user.Save();
                Logger.Info($"Successfully created AD user {samAccountName} with password {password}");
            }
        }

        public void Enable(string samAccountName)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    user.Enabled = true;
                    user.Save();
                    Logger.Info($"Successfully enabled AD account for {samAccountName}");
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }

        public void Disable(string samAccountName)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    user.Enabled = false;
                    user.Save();
                    Logger.Info($"Successfully disabled AD account for {samAccountName}");
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }

        public void SetPassword(string samAccountName, string newPassword)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    user.SetPassword(newPassword);
                    user.Save();
                    Logger.Info($"Successfully set password for {samAccountName}");
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }

        public void SetDescription(string samAccountName, string description)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    user.Description = description;
                    user.Save();
                    Logger.Info($"Successfully set description for {samAccountName}");
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }

        public void SetCompany(string samAccountName, string company)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    user.GetUnderlyingObject().GetType().GetProperty("Company")?.SetValue(user.GetUnderlyingObject(), company);
                    user.Save();
                    Logger.Info($"Successfully set company for {samAccountName}");
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }

        public void ClearExpiration(string samAccountName)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    user.AccountExpirationDate = null;
                    user.Save();
                    Logger.Info($"Successfully cleared account expiration date for {samAccountName}");
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }

        public void AddToGroup(string samAccountName, string groupName)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var group = GroupPrincipal.FindByIdentity(context, groupName);
                if (group != null)
                {
                    var user = UserPrincipal.FindByIdentity(context, samAccountName);
                    if (user != null)
                    {
                        group.Members.Add(user);
                        group.Save();
                        Logger.Info($"Successfully added {samAccountName} to group {groupName}");
                    }
                    else
                    {
                        throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                    }
                }
                else
                {
                    throw new Exception($"No group matches the name: {groupName}");
                }
            }
        }

        public string[] GetGroupMemberships(string samAccountName)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                var user = UserPrincipal.FindByIdentity(context, samAccountName);
                if (user != null)
                {
                    var groups = user.GetGroups().Select(g => g.Name).ToArray();
                    Logger.Info($"Successfully retrieved group memberships for {samAccountName}");
                    return groups;
                }
                else
                {
                    throw new Exception($"No ADUser matches the SAMAccountName: {samAccountName}");
                }
            }
        }
    }
}