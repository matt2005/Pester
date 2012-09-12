function It($name, [ScriptBlock] $test) 
{
    if($test_name -ne $Null -and $test_name.ToLower() -ne $name) {return}
    $results = Get-GlobalTestResults
    $margin = " " * $results.TestDepth
    $error_margin = $margin * 2
    $results.TestCount += 1

    $output = " $margin$name"

    $start_line_position = $test.StartPosition.StartLine
    $test_file = $test.File

    Setup-TestFunction
    . $TestDrive\temp.ps1

    $testResult = @{
        name = $name
        time = 0
        failureMessage = ""
        stackTrace = ""
        success = $false
    };

    Start-PesterConsoleTranscript

    $testTime = Measure-Command {
        try{
            temp
            $testResult.success = $true
        } catch {
            $failure_message = $_.toString() -replace "Exception calling", "Assert failed on"
            $temp_line_number =  $_.InvocationInfo.ScriptLineNumber - 2
            $failure_line_number = $start_line_position + $temp_line_number
            $results.FailedTestsCount += 1
            $testResult.failureMessage = $failure_message
            $testResult.stackTrace = "at line: $failure_line_number in  $test_file"
        }
    }
    
    $testResult.time = $testTime.TotalSeconds
    $humanSeconds = Get-HumanTime $testTime.TotalSeconds
    if($testResult.success) {
        "[+] $output ($humanSeconds)" | Write-Host -ForegroundColor green;
    }
    else {
        "[-] $output ($humanSeconds)" | Write-Host -ForegroundColor red
         Write-Host -ForegroundColor red $error_margin$($testResult.failureMessage)
         Write-Host -ForegroundColor red $error_margin$($testResult.stackTrace)
    }

    $results.CurrentDescribe.Tests += $testResult;
    $results.TotalTime += $testTime.TotalSeconds;
    Stop-PesterConsoleTranscript
}

function Start-PesterConsoleTranscript {
    if (-not (Test-Path $TestDrive\transcripts)) {
        md $TestDrive\transcripts | Out-Null
    }
    Start-Transcript -Path "$TestDrive\transcripts\console.out" | Out-Null
}

function Stop-PesterConsoleTranscript {
    Stop-Transcript | Out-Null
}

function Get-ConsoleText {
    return (Get-Content "$TestDrive\transcripts\console.out")
}

function Setup-TestFunction {
@"
function temp {
$test
}
"@ | out-file $TestDrive\temp.ps1
}
