# 统一模型生成脚本
# 为mobile和desktop项目生成相同的Proto模型

param(
    [switch]$Clean = $false
)

$ErrorActionPreference = "Stop"

# 项目路径
$ProjectRoot = $PSScriptRoot
$ProtoDir = Join-Path $ProjectRoot "protos"
$MobileModelsDir = Join-Path $ProjectRoot "mobile\lib\core\models"
$DesktopModelsDir = Join-Path $ProjectRoot "station\desktop\lib\core\models"

Write-Host "开始生成Proto模型..." -ForegroundColor Green

# 检查protoc是否可用
try {
    $protocVersion = & protoc --version
    Write-Host "使用 $protocVersion" -ForegroundColor Blue
} catch {
    Write-Error "protoc未找到，请安装Protocol Buffers编译器"
    exit 1
}

# 清理旧文件（如果指定）
if ($Clean) {
    Write-Host "清理旧的生成文件..." -ForegroundColor Yellow
    
    # 清理mobile
    if (Test-Path $MobileModelsDir) {
        Get-ChildItem $MobileModelsDir -Filter "*.pb.dart" | Remove-Item -Force
        Get-ChildItem $MobileModelsDir -Filter "*.pbenum.dart" | Remove-Item -Force
        Get-ChildItem $MobileModelsDir -Filter "*.pbjson.dart" | Remove-Item -Force
        Get-ChildItem $MobileModelsDir -Filter "*.pbserver.dart" | Remove-Item -Force
        
        # 删除手写模型
        $handwrittenFiles = @("photo.dart", "photo.g.dart", "user.dart", "user.g.dart")
        foreach ($file in $handwrittenFiles) {
            $filePath = Join-Path $MobileModelsDir $file
            if (Test-Path $filePath) {
                Remove-Item $filePath -Force
                Write-Host "删除手写文件: $file" -ForegroundColor Yellow
            }
        }
        
        # 删除generated目录
        $generatedDir = Join-Path $MobileModelsDir "generated"
        if (Test-Path $generatedDir) {
            Remove-Item $generatedDir -Recurse -Force
            Write-Host "删除generated目录" -ForegroundColor Yellow
        }
    }
    
    # 清理desktop
    if (Test-Path $DesktopModelsDir) {
        Get-ChildItem $DesktopModelsDir -Filter "*.pb.dart" | Remove-Item -Force
        Get-ChildItem $DesktopModelsDir -Filter "*.pbenum.dart" | Remove-Item -Force
        Get-ChildItem $DesktopModelsDir -Filter "*.pbjson.dart" | Remove-Item -Force
        Get-ChildItem $DesktopModelsDir -Filter "*.pbserver.dart" | Remove-Item -Force
        
        # 删除手写模型
        $handwrittenFiles = @("photo.dart", "photo.g.dart", "user.dart", "user.g.dart")
        foreach ($file in $handwrittenFiles) {
            $filePath = Join-Path $DesktopModelsDir $file
            if (Test-Path $filePath) {
                Remove-Item $filePath -Force
                Write-Host "删除手写文件: $file" -ForegroundColor Yellow
            }
        }
        
        # 删除generated目录
        $generatedDir = Join-Path $DesktopModelsDir "generated"
        if (Test-Path $generatedDir) {
            Remove-Item $generatedDir -Recurse -Force
            Write-Host "删除generated目录" -ForegroundColor Yellow
        }
    }
}

# 创建输出目录
New-Item -ItemType Directory -Path $MobileModelsDir -Force | Out-Null
New-Item -ItemType Directory -Path $DesktopModelsDir -Force | Out-Null

# 生成Dart protobuf文件
Write-Host "生成Dart protobuf文件..." -ForegroundColor Blue

# 为mobile生成
Write-Host "为mobile项目生成模型..." -ForegroundColor Cyan
protoc --dart_out=$MobileModelsDir --proto_path=$ProtoDir $ProtoDir\*.proto

# 为desktop生成
Write-Host "为desktop项目生成模型..." -ForegroundColor Cyan
protoc --dart_out=$DesktopModelsDir --proto_path=$ProtoDir $ProtoDir\*.proto

# 重命名文件以符合要求（移除.pb后缀）
function Rename-ProtoFiles {
    param($ModelsDir)
    
    $pbFiles = Get-ChildItem $ModelsDir -Filter "*.pb.dart"
    foreach ($file in $pbFiles) {
        $newName = $file.Name -replace "\.pb\.dart$", ".dart"
        $newPath = Join-Path $ModelsDir $newName
        Move-Item $file.FullName $newPath -Force
        Write-Host "重命名: $($file.Name) -> $newName" -ForegroundColor Green
    }
}

Write-Host "重命名生成的文件..." -ForegroundColor Blue
Rename-ProtoFiles $MobileModelsDir
Rename-ProtoFiles $DesktopModelsDir

Write-Host "模型生成完成！" -ForegroundColor Green
Write-Host "Mobile模型位置: $MobileModelsDir" -ForegroundColor Blue
Write-Host "Desktop模型位置: $DesktopModelsDir" -ForegroundColor Blue