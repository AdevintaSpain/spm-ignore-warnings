
import xcodeproj
import PathKit
import Foundation
import Logger
import IgnoreConfig

let isVerbose = CommandLine.arguments.contains("--verbose") || (ProcessInfo.processInfo.environment["DEBUG"] != nil)
let isSilent = CommandLine.arguments.contains("--silent")
let logger = Logger(isVerbose: isVerbose, isSilent: isSilent)

let config: IgnoreConfig

do {
	config = try IgnoreConfig.load()
} catch {
	logger.logError("failed to get package config with error")
	logger.logError(error)
	exit(1)
}

guard let projectPath = try? Path.current.children().filter({ path in
	guard let last = path.components.last else {
		return false
	}

	return last.contains("xcodeproj")
}).first else {
	logger.logError("failed to unwrap project path")
	exit(1)
}

guard let project = try? XcodeProj(path: projectPath) else {
	logger.logError("failed to load project")
	exit(1)
}

let ignored = project.pbxproj.nativeTargets.filter({ !config.excludedTargets.contains($0.name) })

for target in ignored {
	guard let configurations = target.buildConfigurationList?.buildConfigurations else {
		continue
	}

	for rule in target.buildRules {
		rule.outputFilesCompilerFlags?.append("-w -Xanalyzer -analyzer-disable-all-checks")
	}

	for configuration in configurations {
		configuration.buildSettings["SWIFT_SUPPRESS_WARNINGS"] = "YES"
		configuration.buildSettings["GCC_WARN_INHIBIT_ALL_WARNINGS"] = "YES"
		
	}
}

guard let _ = try? project.writePBXProj(path: projectPath, override: true, outputSettings: PBXOutputSettings()) else {
	logger.logError("failed to save project")
	exit(1)
}

exit(0)

#warning("this warning should be ignored in the resulting target")
