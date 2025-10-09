package logger

import (
    "github.com/cloudwego/hertz/pkg/common/hlog"
    hertzzap "github.com/hertz-contrib/logger/zap"
    "go.uber.org/zap"
)

var S *zap.SugaredLogger

// Init initializes zap logger and sets it to Hertz's hlog, also exposes a global SugaredLogger.
func Init() {
    // Set Hertz's logger to zap adapter (framework logs)
    hzLogger := hertzzap.NewLogger()
    hzLogger.SetLevel(hlog.LevelDebug)
    hlog.SetLogger(hzLogger)

    // Create application-level zap logger
    zl, _ := zap.NewProduction()
    S = zl.Sugar()
}

// Lightweight proxies for direct usage: logger.Infof/Info/Warnf/Errorf/Fatalf
func Infof(format string, args ...interface{}) { S.Infof(format, args...) }
func Info(args ...interface{}) { S.Info(args...) }
func Warnf(format string, args ...interface{}) { S.Warnf(format, args...) }
func Errorf(format string, args ...interface{}) { S.Errorf(format, args...) }
func Fatalf(format string, args ...interface{}) { S.Fatalf(format, args...) }
