using System;
using System.IO;

namespace ADUserLibrary
{
    public enum LogLevel
    {
        Info = 1,
        Warning = 2,
        Error = 3
    }

    public class Logger
    {
        public string LogFilePath { get; set; }
        public LogLevel MinimumLogLevel { get; set; }

        public Logger(string logFilePath = ".\\log.txt", LogLevel minimumLogLevel = LogLevel.Info)
        {
            LogFilePath = logFilePath;
            MinimumLogLevel = minimumLogLevel;
        }

        private void WriteLogEntry(LogLevel level, string message)
        {
            if ((int)level >= (int)MinimumLogLevel)
            {
                string logEntry = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} [{level}] {message}";
                File.AppendAllText(LogFilePath, logEntry + Environment.NewLine);
                Console.WriteLine(logEntry);
            }
        }

        public void Info(string message)
        {
            WriteLogEntry(LogLevel.Info, message);
        }

        public void Warning(string message)
        {
            WriteLogEntry(LogLevel.Warning, message);
        }

        public void Error(string message)
        {
            WriteLogEntry(LogLevel.Error, message);
        }
    }
}