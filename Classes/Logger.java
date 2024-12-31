package com.example.aduser;

import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Logger {
    public enum LogLevel {
        INFO,
        WARNING,
        ERROR
    }

    private String logFilePath;
    private LogLevel minimumLogLevel;

    public Logger(String logFilePath, LogLevel minimumLogLevel) {
        this.logFilePath = logFilePath;
        this.minimumLogLevel = minimumLogLevel;
    }

    private void writeLogEntry(LogLevel level, String message) {
        if (level.ordinal() >= minimumLogLevel.ordinal()) {
            String logEntry = String.format("%s [%s] %s",
                    LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")),
                    level, message);
            try (FileWriter writer = new FileWriter(logFilePath, true)) {
                writer.write(logEntry + System.lineSeparator());
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.out.println(logEntry);
        }
    }

    public void info(String message) {
        writeLogEntry(LogLevel.INFO, message);
    }

    public void warning(String message) {
        writeLogEntry(LogLevel.WARNING, message);
    }

    public void error(String message) {
        writeLogEntry(LogLevel.ERROR, message);
    }
}