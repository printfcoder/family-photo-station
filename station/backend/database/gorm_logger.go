package database

import (
    "context"
    "errors"
    "time"

    appLog "github.com/printfcoder/family-photo-station/logger"
    "gorm.io/gorm"
    gormLogger "gorm.io/gorm/logger"
    "gorm.io/gorm/utils"
)

// GormLogger adapts application logger to GORM's logger.Interface
type GormLogger struct {
    LogLevel                   gormLogger.LogLevel
    SlowThreshold              time.Duration
    IgnoreRecordNotFoundError  bool
    Colorful                   bool
}

// NewGormLogger creates a new GormLogger with sane defaults
func NewGormLogger() gormLogger.Interface {
    return &GormLogger{
        LogLevel:                  gormLogger.Warn,
        SlowThreshold:             200 * time.Millisecond,
        IgnoreRecordNotFoundError: true,
        Colorful:                  false,
    }
}

// LogMode sets the logging level for GORM
func (l *GormLogger) LogMode(level gormLogger.LogLevel) gormLogger.Interface {
    newlogger := *l
    newlogger.LogLevel = level
    return &newlogger
}

// Info logs general info messages when level allows
func (l *GormLogger) Info(ctx context.Context, msg string, data ...interface{}) {
    if l.LogLevel >= gormLogger.Info {
        appLog.Infof(msg, data...)
    }
}

// Warn logs warning messages when level allows
func (l *GormLogger) Warn(ctx context.Context, msg string, data ...interface{}) {
    if l.LogLevel >= gormLogger.Warn {
        appLog.Warnf(msg, data...)
    }
}

// Error logs error messages when level allows
func (l *GormLogger) Error(ctx context.Context, msg string, data ...interface{}) {
    if l.LogLevel >= gormLogger.Error {
        appLog.Errorf(msg, data...)
    }
}

// Trace logs SQL execution details based on elapsed time and error
func (l *GormLogger) Trace(ctx context.Context, begin time.Time, fc func() (sql string, rows int64), err error) {
    if l.LogLevel == gormLogger.Silent {
        return
    }

    elapsed := time.Since(begin)
    sql, rows := fc()
    fileWithLineNum := utils.FileWithLineNum()

    switch {
    case err != nil && l.LogLevel >= gormLogger.Error && (!errors.Is(err, gorm.ErrRecordNotFound) || !l.IgnoreRecordNotFoundError):
        appLog.Errorf("GORM Error %s [%.3fms] [rows:%v] %s | %s", err, float64(elapsed.Microseconds())/1000.0, rows, sql, fileWithLineNum)
    case l.SlowThreshold != 0 && elapsed > l.SlowThreshold && l.LogLevel >= gormLogger.Warn:
        appLog.Warnf("GORM Slow SQL [%.3fms] [rows:%v] %s | %s", float64(elapsed.Microseconds())/1000.0, rows, sql, fileWithLineNum)
    case l.LogLevel >= gormLogger.Info:
        appLog.Infof("GORM SQL [%.3fms] [rows:%v] %s | %s", float64(elapsed.Microseconds())/1000.0, rows, sql, fileWithLineNum)
    }
}