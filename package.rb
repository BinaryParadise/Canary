#!/usr/bin/ruby -W0

require 'tmpdir'
require 'yaml'

# 打包脚本
class CNPackage
    def initialize(args)
        cloneDir = Dir.tmpdir
        Dir.chdir(cloneDir)
        puts "拉取代码"
        `git clone #{args[0]} --depth=1`
        config = YAML.load_file(Pathname("config.yml").to_path)
        `pod install`
        puts "打包中..."
        `xcodebuild archive -workspace "#{config.workspace}"  -scheme "#{args[1]}" -configuration Test -archivePath build/product.xcarchive > build/output.log`
        puts "正在导出..."
        `xcodebuild -exportArchive -archivePath build/product.xcarchive -exportPath build/Products -exportOptionsPlist build/ExportOptions.plist`
    end
end

CNPackage::new(ARGV)