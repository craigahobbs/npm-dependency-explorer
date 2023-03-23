# semver.mds Tests

~~~ markdown-script
include '../semver.mds'
include '../include/unittest.mds'


function testSemverParse()
    unittestDeepEquals( \
        semverParse('1.2.3-beta.1+1234'), \
        jsonParse('{"build": "1234", "major": 1, "minor": 2, "patch": 3, "release": ["beta",1]}') \
    )
endfunction
unittestRunTest('testSemverParse')


function testSemverStringify()
    unittestDeepEquals( \
        semverStringify(semverParse('1.2.3-beta.1+1234')), \
        '1.2.3-beta.1+1234' \
    )
endfunction
unittestRunTest('testSemverStringify')


function testSemverCompare_release()
    semver = semverParse('1.2.3-beta.1+1234')
    other = semverParse('1.2.2-rc.2+1235')
    unittestEquals(semverCompare(semver, other), 1)
    unittestEquals(semverCompare(other, semver), -1)
    unittestEquals(semverCompare(semver, semver), 0)
    unittestEquals(semverCompare(other, other), 0)
endfunction
unittestRunTest('testSemverCompare_release')


function testSemverCompare_releaseSame()
    semver = semverParse('1.2.3-beta.1+1234')
    other = semverParse('1.2.3-beta.2+1235')
    unittestEquals(semverCompare(semver, other), -1)
    unittestEquals(semverCompare(other, semver), 1)
    unittestEquals(semverCompare(semver, semver), 0)
    unittestEquals(semverCompare(other, other), 0)
endfunction
unittestRunTest('testSemverCompare_releaseSame')


function testSemverVersions()
    versions = semverVersions(arrayNew('1.2.2', '1.2.2-rc.2+1235'))
    dataCalculatedField(versions, 'semver', 'semver != null')
    unittestDeepEquals( \
        versions, \
        arrayNew( \
            jsonParse('{"build": null, "major": 1, "minor": 2, "patch": 2, "release": null, "semver": true}'), \
            jsonParse('{"build": "1235", "major": 1, "minor": 2, "patch": 2, "release": ["rc", 2], "semver": true}') \
        ) \
    )
endfunction
unittestRunTest('testSemverVersions')


function testSemverMatch_parts()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1' \
    ))
    foreach rangeVersion in arrayNew( \
        arrayNew('1.0.1 || >= 1.1.1 < 2.0.0', '1.1.3') \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_parts')


function testSemverMatch_range()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1' \
    ))
    foreach rangeVersion in arrayNew( \
        arrayNew('1.0.1', '1.0.1'), \
        arrayNew('1.0.4', null), \
        arrayNew('= 1.0.1', '1.0.1'), \
        arrayNew('= 1.0.4', null), \
        arrayNew('> 1.0.1', '2.0.1'), \
        arrayNew('> 3.0.0', null), \
        arrayNew('>= 1.0.1', '2.0.1'), \
        arrayNew('>= 3.0.0', null), \
        arrayNew('< 1.0.2', '1.0.1'), \
        arrayNew('< 1.0.0', null), \
        arrayNew('<= 1.0.2', '1.0.2'), \
        arrayNew('<= 0.0.0', null), \
        arrayNew('>= 1.0.2 < 2.0.0', '1.1.3') \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_range')


function testSemverMatch_hyphen()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1' \
    ))
    foreach rangeVersion in arrayNew( \
        arrayNew('1 - 2', '1.1.3'), \
        arrayNew('1.0 - 2.0', '1.1.3'), \
        arrayNew('1.0.0 - 2.0', '1.1.3'), \
        arrayNew('1.0.0 - 2.0.0', '2.0.0'), \
        arrayNew('1.0. - 2.0', null), \
        arrayNew('1.0 - 2.0.', null), \
        arrayNew('1. - 2', null), \
        arrayNew('1 - 2.', null), \
        arrayNew(' - 2.', null), \
        arrayNew('1 -', null) \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_hyphen')


function testSemverMatch_xRange()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1', \
        '2.1.0-beta.1' \
    ))
    foreach rangeVersion in arrayNew( \
        arrayNew('', '2.0.1'), \
        arrayNew('*', '2.0.1'), \
        arrayNew('1', '1.1.3', '1'), \
        arrayNew('1.x', '1.1.3'), \
        arrayNew('1.x.x', '1.1.3'), \
        arrayNew('1.x.', null), \
        arrayNew('1.', null) \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_xRange')


function testSemverMatch_tilde()
    versions = semverVersions(arrayNew('1.2.2', '1.2.2-rc.2+1235'))
    foreach rangeVersion in arrayNew( \
        arrayNew('~1.2', '1.2.2'), \
        arrayNew('~1.3', null) \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_tilde')


function testSemverMatch_carrot()
    versions = semverVersions(arrayNew(\
        '0.0.1', '0.0.2', '0.0.3', \
        '0.1.1', '0.1.2', '0.1.3', \
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '1.2.1-beta.1', '1.2.1-beta.2', \
        '2.0.0' \
    ))
    foreach rangeVersion in arrayNew( \
        arrayNew('^0.0.1', '0.0.1'), \
        arrayNew('^0.0.3', '0.0.3'), \
        arrayNew('^0.0.4', null), \
        arrayNew('^0.1.1', '0.1.3'), \
        arrayNew('^0.1.3', '0.1.3'), \
        arrayNew('^0.1.4', null), \
        arrayNew('^1.0.1', '1.1.3'), \
        arrayNew('^1.0.3', '1.1.3'), \
        arrayNew('^1.0.4', '1.1.3'), \
        arrayNew('^1.1.1', '1.1.3'), \
        arrayNew('^1.1.3', '1.1.3'), \
        arrayNew('^1.1.4', null), \
        arrayNew('^1.2.1-beta.1', '1.2.1-beta.2'), \
        arrayNew('^1.2.1', null), \
        arrayNew('^2.0.0', '2.0.0') \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_carrot')


function testSemverMatch_space()
    versions = semverVersions(arrayNew(\
        '0.0.1', '0.0.2', '0.0.3', \
        '0.1.1', '0.1.2', '0.1.3', \
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3' \
    ))
    foreach rangeVersion in arrayNew( \
        arrayNew(' ', '1.1.3'), \
        arrayNew(' ^ 1.0.1 ', '1.1.3'), \
        arrayNew(' ~ 1.0.1 ', '1.0.3'), \
        arrayNew(' 1.0.1  -  2 ', '1.1.3'), \
        arrayNew(' >= 1 < 2 ', '1.1.3'), \
        arrayNew(' 1 ', '1.1.3') \
    ) do
        range = arrayGet(rangeVersion, 0)
        version = arrayGet(rangeVersion, 1)
        unittestEquals(semverMatch(versions, range), version, jsonStringify(range))
    endforeach
endfunction
unittestRunTest('testSemverMatch_space')


unittestReport()
~~~
