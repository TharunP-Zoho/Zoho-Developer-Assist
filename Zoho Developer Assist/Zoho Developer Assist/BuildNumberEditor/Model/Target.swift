//
//  Target.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 05/06/21.
//

import Foundation

struct BuildConfig: Hashable
{
    var id = ""
    var name = ""
}

struct Target: Hashable
{
    var name = ""
    var buildConfig = [BuildConfig]()
    var buildNumber = ""
    var versionNumber = ""
    var newBuildNumber = ""
    var newVersionNumber = ""
    var selected = true
    var isTestTarget = false
    
}
