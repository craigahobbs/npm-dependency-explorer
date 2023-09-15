~~~ markdown-script
# Licensed under the MIT License
# https://github.com/craigahobbs/npm-dependency-explorer/blob/main/LICENSE

include <forms.mds>
include 'npm.mds'


# The npm Dependency Explorer main entry point
async function ndeMain():
    # Variable arguments
    packageName = if(vName != null && stringLength(vName) > 0, vName, null)
    packageVersion = if(vVersion != null && stringLength(vVersion) > 0, vVersion, null)
    dependencyKey = if(vType == 'Development', 'devDependencies', 'dependencies')

    # Load the package version dependency data
    cache = npmCacheNew()
    if packageName != null:
        packageVersion = npmCacheLoadPackage(cache, packageName, packageVersion, dependencyKey)
    endif
    packageData = npmCacheGetPackage(cache, packageName)
    packageJSON = if(packageData != null, npmPackageJSON(packageData, packageVersion))

    # Render the menu
    currentURL = ndeURL(objectNew())
    markdownPrint(if(currentURL != '#var=', '[Home](#var=)', 'Home') + ' | [About](#url=README.md)')

    # Render the title
    title = 'npm Dependency Explorer'
    markdownPrint('', '# ' + markdownEscape(title))
    documentSetTitle(title + if(packageJSON != null, ' - ' + packageName, ''))

    # If no package is loaded, render the package selection form
    if packageJSON == null:
        ndeRenderForm(cache, packageName, packageVersion)
        return
    endif

    # Render the package header
    markdownPrint( \
        '', \
        '## [' + markdownEscape(packageName) + '](' + npmPackagePageURL(packageName) + ')', \
        '', \
        '**Description:** ' + markdownEscape(objectGet(packageJSON, 'description')) \
    )

    # Render the package version selection links?
    if vVersionSelect:
        ndeRenderVersionLinks(cache, packageName, packageVersion)
        return

    # Render the package version dependency chart?
    elif vVersionChart:
        ndeRenderVersionChart(cache, packageName, packageVersion, dependencyKey)
        return
    endif

    # Render the package version
    markdownPrint( \
        '', \
        '**Version:** ' + markdownEscape(packageVersion), \
        '([versions](' + ndeURL(objectNew('versionSelect', 1)) + ') | ', \
        '[chart](' + ndeURL(objectNew('versionChart', 1)) + '))' \
    )

    # Load all dependencies and compute the dependency statistics
    dependencyStats = npmPackageStats(cache, packageName, packageVersion, dependencyKey)
    dependenciesFiltered = objectGet(dependencyStats, if(vDirect, 'dependenciesDirect', 'dependencies'))
    warnings = objectGet(dependencyStats, 'warnings')

    # Filter to dependencies that have a newer version?
    hasLatest = arrayLength(dataFilter(dependenciesFiltered, "Latest != ''")) > 0
    if hasLatest && vLatest:
        dependenciesFiltered = dataFilter(dependenciesFiltered, "Latest != ''")
    endif

    # Compute the dependency type links
    linkPackage = if(dependencyKey != 'devDependencies', 'Package', '[Package](' + ndeURL(objectNew('type', '')) + ')')
    linkDevelopment = if(dependencyKey == 'devDependencies', 'Development', '[Development](' + ndeURL(objectNew('type', 'Development')) + ')')

    # Render the package dependency stats
    dependenciesDescriptor = if(dependencyKey == 'devDependencies', '*Development* ', '')
    markdownPrint( \
        '', \
        '**Direct ' + dependenciesDescriptor + 'dependencies:** ' + objectGet(dependencyStats, 'countDirect') + ' \\', \
        '**Total ' + dependenciesDescriptor + 'dependencies:** ' + objectGet(dependencyStats, 'count'), \
        '', \
        '**Type:** ' + linkPackage + ' | ' + linkDevelopment \
    )

    # Render warnings
    if arrayLength(warnings):
        markdownPrint( \
            '', \
            '### Warnings', \
            '', \
            'There are ' + arrayLength(warnings) + ' warnings.' + stringFromCharCode(160), \
            '[' + if(vWarn, 'Hide', 'Show') + '](' + ndeURL(objectNew('warn', !vWarn)) + ')' \
        )
        if vWarn:
            for warning in warnings:
                markdownPrint('', '- ' + markdownEscape(warning))
            endfor
        endif
    endif

    # Render the dependency table
    if arrayLength(dependenciesFiltered):
        # Compute the sort links
        linkSortName = if(vSort != 'Dependencies', 'Name', '[Name](' + ndeURL(objectNew('sort', '')) + ')')
        linkSortDependencies = if(vSort == 'Dependencies', 'Dependencies', '[Dependencies](' + ndeURL(objectNew('sort', 'Dependencies')) + ')')

        # Compute the direct filter links
        linkDirectAll = if(!vDirect, 'All', '[All](' + ndeURL(objectNew('direct', 0)) + ')')
        linkDirect = if(vDirect, 'Direct', '[Direct](' + ndeURL(objectNew('direct', 1)) + ')')

        # Compute the latest filter links
        linkLatestAll = if(!vLatest, 'All', '[All](' + ndeURL(objectNew('latest', 0)) + ')')
        linkLatest = if(vLatest, 'Latest', '[Latest](' + ndeURL(objectNew('latest', 1)) + ')')

        # Render the filter/sort links
        markdownPrint( \
            '', \
            '### ' + if(dependencyKey == 'devDependencies', 'Development ', '') + 'Dependencies', \
            '', \
            '**Sort:** ' + linkSortName + ' | ' + linkSortDependencies + ' \\', \
            '**Direct:** ' + linkDirectAll + ' | ' + linkDirect + if(hasLatest, ' \\', ''), \
            if(hasLatest, '**Latest:** ' + linkLatestAll + ' | ' + linkLatest, '') \
        )

        # Add the dependency count field
        dataCalculatedField(dependenciesFiltered, 'Dependencies', 'npmPackageDependencyCount(cache, Package, Version, "dependencies")', \
            objectNew('cache', cache))

        # Sort the table data
        sortFields = arrayNew(arrayNew('Package'), arrayNew('Version'), arrayNew('Dependent'), arrayNew('Dependent Version'))
        if vSort == 'Dependencies':
            sortFields = arrayExtend(arrayNew(arrayNew('Dependencies', 1)), sortFields)
        endif
        dataSort(dependenciesFiltered, sortFields)

        # Make the name field links
        dataCalculatedField(dependenciesFiltered, 'Package', \
            "'[' + markdownEscape(Package) + '](' + ndeCleanURL(objectNew('name', Package, 'version', Version)) + ')'")
        dataCalculatedField(dependenciesFiltered, 'Dependent', \
            "'[' + markdownEscape(Dependent) + '](' + ndeCleanURL(objectNew('name', Dependent, 'version', [Dependent Version])) + ')'")

        # Render the dependencies table
        dataTable(dependenciesFiltered, objectNew( \
            'categories', arrayNew('Package', 'Version'), \
            'fields', if(hasLatest, \
                arrayNew('Latest', 'Range', 'Dependent', 'Dependent Version', 'Dependencies'), \
                arrayNew('Range', 'Dependent', 'Dependent Version', 'Dependencies') \
            ), \
            'formats', objectNew( \
                'Package', objectNew('markdown', true), \
                'Dependent', objectNew('markdown', true) \
            ) \
        ))
    endif
endfunction


# Render the package selection form
function ndeRenderForm(cache, packageName, packageVersion):
    # Render the search form
    elementModelRender(arrayNew( \
        objectNew('html', 'p', 'elem', objectNew('html', 'b', 'elem', objectNew('text', 'Package Name:'))), \
        objectNew('html', 'p', 'elem', formsTextElements('package-name-text', packageName, 32, ndePackageNameOnClick)), \
        objectNew('html', 'p', 'elem', formsLinkButtonElements('Explore Dependencies', ndePackageNameOnClick)) \
    ))
    documentSetFocus('package-name-text')

    # Render error messages
    if packageName != null:
        packageData = npmCacheGetPackage(cache, packageName)
        if packageData == null:
            markdownPrint('', '**Error:** Unknown package "' + markdownEscape(packageName) + '"')
        elif packageVersion != null && npmPackageJSON(packageData, packageVersion) == null:
            markdownPrint('', '**Error:** Unknown version "' + markdownEscape(packageVersion) + '" of package "' + \
                markdownEscape(packageName) + '"')
        endif
    endif

    # Render example packages
    markdownPrint('', '## Examples')
    for exampleName in arraySort(arrayNew( \
        'c8', 'eslint', 'jsdoc', 'jsdom', 'npm', \
        'bare-script', 'element-model', 'markdown-model', 'markdown-up', 'schema-markdown' \
    )):
        markdownPrint('', '[' + markdownEscape(exampleName) + "](#var.vName='" + urlEncodeComponent(exampleName) + "')")
    endfor
endfunction


# Package name button on-click handler
function ndePackageNameOnClick():
    packageName = stringTrim(documentInputValue('package-name-text'))
    windowSetLocation(ndeCleanURL(objectNew('name', packageName)))
endfunction


# Render the package version links
function ndeRenderVersionLinks(cache, packageName, packageVersion):
    markdownPrint( \
        '', \
        '[Back to package](' + ndeURL(objectNew('versionSelect', 0)) + ')', \
        '', \
        '### Versions' \
    )
    packageSemvers = npmCacheGetPackageVersions(cache, packageName)
    packageVersionLatest = npmPackageVersionLatest(npmCacheGetPackage(cache, packageName))
    for packageSemver in packageSemvers:
        packageVersion = semverStringify(packageSemver)
        markdownPrint('', '[' + markdownEscape(packageVersion) + '](' + \
            ndeURL(objectNew('version', packageVersion, 'versionSelect', 0)) + ')' + \
            if(packageVersion == packageVersionLatest, ' (latest)', ''))
    endfor
endfunction


# Render the package dependencies by version chart
async function ndeRenderVersionChart(cache, packageName, packageVersion, dependencyKey):
    markdownPrint( \
        '', \
        '[Back to package](' + ndeURL(objectNew('versionChart', 0)) + ')', \
        '', \
        '### ' + if(dependencyKey == 'devDependencies', '*Development* ', '') + 'Dependencies Chart' \
    )

    # Load all package version dependencies
    npmCacheLoadPackageAll(cache, packageName, dependencyKey)

    # Compute the version dependency data table
    versionDependencies = arrayNew()
    packageSemvers = npmCacheGetPackageVersions(cache, packageName)
    packageSemverCount = arrayLength(packageSemvers)
    for packageSemver, ixSemver in packageSemvers:
        packageVersion = semverStringify(packageSemver)
        packageVersionURL = ndeURL(objectNew('version', packageVersion, 'versionChart', 0))
        arrayPush(versionDependencies, objectNew( \
            'Version Index', packageSemverCount - ixSemver - 1, \
            'Version', '[' + markdownEscape(packageVersion) + '](' + packageVersionURL + ')', \
            'Dependencies', npmPackageDependencyCount(cache, packageName, packageVersion, dependencyKey) \
        ))
    endfor

    # Render the version dependency data as a line chart and as a table
    dataLineChart(versionDependencies, objectNew( \
        'width', 800, \
        'height', 300, \
        'x', 'Version Index', \
        'y', arrayNew('Dependencies'), \
        'xTicks', objectNew('count', 5), \
        'yTicks', objectNew('count', 5, 'start', 0), \
        'precision', 1 \
    ))
    dataSort(versionDependencies, arrayNew(arrayNew('Version Index', 1)))
    dataTable(versionDependencies, objectNew( \
        'fields', arrayNew('Version Index', 'Version', 'Dependencies'), \
        'formats', objectNew( \
            'Version', objectNew('markdown', true) \
        ) \
    ))
endfunction


# Helper to create application links
function ndeURL(args):
    # Arguments overrides
    name = objectGet(args, 'name')
    version = objectGet(args, 'version')
    versionChart = objectGet(args, 'versionChart')
    versionSelect = objectGet(args, 'versionSelect')
    type = objectGet(args, 'type')
    direct = objectGet(args, 'direct')
    latest = objectGet(args, 'latest')
    sort = objectGet(args, 'sort')
    warn = objectGet(args, 'warn')

    # Variable arguments
    name = if(name != null, name, vName)
    version = if(version != null, version, vVersion)
    type = if(type != null, type, vType)
    direct = if(direct != null, direct, vDirect)
    latest = if(latest != null, latest, vLatest)
    sort = if(sort != null, sort, vSort)
    warn = if(warn != null, warn, vWarn)

    # Cleared arguments
    name = if(name != null && stringLength(name) > 0, name)
    version = if(version != null && stringLength(version) > 0, version)
    type = if(type != null && stringLength(type) > 0, type)
    sort = if(sort != null && stringLength(sort) > 0, sort)

    # Create the link
    parts = arrayNew()
    if(direct != null && direct, arrayPush(parts, 'var.vDirect=1'))
    if(latest != null && latest, arrayPush(parts, 'var.vLatest=1'))
    if(name != null, arrayPush(parts, "var.vName='" + urlEncodeComponent(name) + "'"))
    if(sort != null, arrayPush(parts, "var.vSort='" + urlEncodeComponent(sort) + "'"))
    if(type != null, arrayPush(parts, "var.vType='" + urlEncodeComponent(type) + "'"))
    if(version != null, arrayPush(parts, "var.vVersion='" + urlEncodeComponent(version) + "'"))
    if(versionChart != null && versionChart, arrayPush(parts, 'var.vVersionChart=1'))
    if(versionSelect != null && versionSelect, arrayPush(parts, 'var.vVersionSelect=1'))
    if(warn != null && warn, arrayPush(parts, 'var.vWarn=1'))
    return if(arrayLength(parts) != 0, '#' + arrayJoin(parts, '&'), '#var=')
endfunction


# Helper to create package/version application links
function ndeCleanURL(args):
    argsClean = objectNew( \
        'name', '', \
        'version', '', \
        'versionChart', 0, \
        'versionSelect', 0, \
        'type', '', \
        'direct', 0, \
        'latest', 0, \
        'sort', '', \
        'warn', 0 \
     )
    return ndeURL(objectAssign(argsClean, args))
endfunction


# Call the main entry point
ndeMain()
~~~
