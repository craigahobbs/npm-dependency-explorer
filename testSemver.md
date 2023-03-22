# semver Tests

~~~ markdown-script
include 'semver.mds'
include 'unittest.mds'


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


function testSemverMatch_range()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1' \
    ))
    unittestEquals(semverMatch(versions, '1.0.1'), '1.0.1')
    unittestEquals(semverMatch(versions, '1.0.4'), null)
    unittestEquals(semverMatch(versions, '= 1.0.1'), '1.0.1')
    unittestEquals(semverMatch(versions, '= 1.0.4'), null)
endfunction
unittestRunTest('testSemverMatch_range')


function testSemverMatch_hyphen()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1' \
    ))
    unittestEquals(semverMatch(versions, '1 - 2'), '1.1.3')
    unittestEquals(semverMatch(versions, '1.0 - 2.0'), '1.1.3')
    unittestEquals(semverMatch(versions, '1.0.0 - 2.0'), '1.1.3')
    unittestEquals(semverMatch(versions, '1.0.0 - 2.0.0'), '2.0.0')
    unittestEquals(semverMatch(versions, '1.0. - 2.0'), null)
    unittestEquals(semverMatch(versions, '1.0 - 2.0.'), null)
    unittestEquals(semverMatch(versions, '1. - 2'), null)
    unittestEquals(semverMatch(versions, '1 - 2.'), null)
    unittestEquals(semverMatch(versions, ' - 2.'), null)
    unittestEquals(semverMatch(versions, '1 -'), null)
endfunction
unittestRunTest('testSemverMatch_hyphen')


function testSemverMatch_xRange()
    versions = semverVersions(arrayNew(\
        '1.0.1', '1.0.2', '1.0.3', \
        '1.1.1', '1.1.2', '1.1.3', \
        '2.0.0-beta.1', '2.0.0', '2.0.1', \
        '2.1.0-beta.1' \
    ))
    unittestEquals(semverMatch(versions, ''), '2.0.1')
    unittestEquals(semverMatch(versions, '*'), '2.0.1')
    unittestEquals(semverMatch(versions, '1'), '1.1.3', '1')
    unittestEquals(semverMatch(versions, '1.x'), '1.1.3')
    unittestEquals(semverMatch(versions, '1.x.x'), '1.1.3')
    unittestEquals(semverMatch(versions, '1.x.'), null)
    unittestEquals(semverMatch(versions, '1.'), null)
endfunction
unittestRunTest('testSemverMatch_xRange')


function testSemverMatch_tilde()
    versions = semverVersions(arrayNew('1.2.2', '1.2.2-rc.2+1235'))
    unittestEquals(semverMatch(versions, '~1.2'), '1.2.2')
    unittestEquals(semverMatch(versions, '~1.3'), null)
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
    unittestEquals(semverMatch(versions, '^0.0.1'), '0.0.1')
    unittestEquals(semverMatch(versions, '^0.0.3'), '0.0.3')
    unittestEquals(semverMatch(versions, '^0.0.4'), null)
    unittestEquals(semverMatch(versions, '^0.1.1'), '0.1.3')
    unittestEquals(semverMatch(versions, '^0.1.3'), '0.1.3')
    unittestEquals(semverMatch(versions, '^0.1.4'), null)
    unittestEquals(semverMatch(versions, '^1.0.1'), '1.1.3')
    unittestEquals(semverMatch(versions, '^1.0.3'), '1.1.3')
    unittestEquals(semverMatch(versions, '^1.0.4'), '1.1.3')
    unittestEquals(semverMatch(versions, '^1.1.1'), '1.1.3')
    unittestEquals(semverMatch(versions, '^1.1.3'), '1.1.3')
    unittestEquals(semverMatch(versions, '^1.1.4'), null)
    unittestEquals(semverMatch(versions, '^1.2.1-beta.1'), '1.2.1-beta.2')
    unittestEquals(semverMatch(versions, '^1.2.1'), null)
    unittestEquals(semverMatch(versions, '^2.0.0'), '2.0.0')
endfunction
unittestRunTest('testSemverMatch_carrot')


unittestReport()
~~~
