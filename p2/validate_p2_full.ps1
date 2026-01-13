# validate_p2_full.ps1
# Complete Part 2 Validation Script - Runs from Windows Host

$VM_NAME = "HdagdaguS"
$IP = "192.168.56.110"

# Counters for summary
$passed = 0
$failed = 0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   PART 2 - FULL VALIDATION SCRIPT" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================
# SECTION 1: VM INTERNAL CHECKS (via SSH)
# ============================================
Write-Host "[SECTION 1] VM Internal Checks (via SSH)" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# 1.1 Check Node Status
Write-Host "`n[1.1] Checking Node Status..." -ForegroundColor Magenta
$nodeOutput = vagrant ssh $VM_NAME -c "sudo kubectl get nodes -o wide"2>$null
Write-Host $nodeOutput
if ($nodeOutput -match "Ready") {
    Write-Host "[PASS] Node is Ready" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] Node is NOT Ready" -ForegroundColor Red
    $failed++
}

# 1.2 Check Deployments (Replicas)
Write-Host "`n[1.2] Checking Deployments..." -ForegroundColor Magenta
$deployOutput = vagrant ssh $VM_NAME -c "sudo kubectl get deployments" 2>$null
Write-Host $deployOutput

# Check app-one (1 replica)
if ($deployOutput -match "app-one\s+1/1") {
    Write-Host "[PASS] app-one: 1/1 replicas" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] app-one: NOT 1/1 replicas" -ForegroundColor Red
    $failed++
}

# Check app-two (3 replicas - REQUIRED)
if ($deployOutput -match "app-two\s+3/3") {
    Write-Host "[PASS] app-two: 3/3 replicas (REQUIRED)" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] app-two: NOT 3/3 replicas (REQUIRED)" -ForegroundColor Red
    $failed++
}

# Check app-three (1 replica)
if ($deployOutput -match "app-three\s+1/1") {
    Write-Host "[PASS] app-three: 1/1 replicas" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] app-three: NOT 1/1 replicas" -ForegroundColor Red
    $failed++
}

# 1.3 Check Pods
Write-Host "`n[1.3] Checking Pods..." -ForegroundColor Magenta
$podsOutput = vagrant ssh $VM_NAME -c "sudo kubectl get pods" 2>$null
Write-Host $podsOutput
$runningPods = ([regex]::Matches($podsOutput, "Running")).Count
if ($runningPods -eq 5) {
    Write-Host "[PASS]5 pods running (1+3+1)" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] Expected 5 running pods, found $runningPods" -ForegroundColor Red
    $failed++
}

# 1.4 Check Services
Write-Host "`n[1.4] Checking Services..." -ForegroundColor Magenta
$svcOutput = vagrant ssh $VM_NAME -c "sudo kubectl get svc" 2>$null
Write-Host $svcOutput

$svcChecks = @("app-one-service", "app-two-service", "app-three-service")
foreach ($svc in $svcChecks) {
    if ($svcOutput -match $svc) {
        Write-Host "[PASS] $svc exists" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[FAIL] $svc NOT found" -ForegroundColor Red
        $failed++
    }
}

# 1.5 Check Ingress
Write-Host "`n[1.5] Checking Ingress..." -ForegroundColor Magenta
$ingressOutput = vagrant ssh $VM_NAME -c "sudo kubectl get ingress" 2>$null
Write-Host $ingressOutput
if ($ingressOutput -match "iot-ingress.*$IP") {
    Write-Host "[PASS] Ingress has correct IP ($IP)" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] Ingress IP mismatch or not found" -ForegroundColor Red
    $failed++
}

# 1.6 Describe Ingress (Detailed Rules)
Write-Host "`n[1.6] Ingress Rules (Detailed)..." -ForegroundColor Magenta
$describeOutput = vagrant ssh $VM_NAME -c "sudo kubectl describe ingress iot-ingress" 2>$null
Write-Host $describeOutput

# Check routing rules
if ($describeOutput -match "app1.com") {
    Write-Host "[PASS] app1.com rule configured" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] app1.com routing not configured" -ForegroundColor Red
    $failed++
}

if ($describeOutput -match "app2.com") {
    Write-Host "[PASS] app2.com rule configured" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] app2.com routing not configured" -ForegroundColor Red
    $failed++
}

if ($describeOutput -match "\*") {
    Write-Host "[PASS] Default (*) rule configured" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] Default routing not configured" -ForegroundColor Red
    $failed++
}

# 1.7 Check Hostname
Write-Host "`n[1.7] Checking VM Hostname..." -ForegroundColor Magenta
$hostname = (vagrant ssh $VM_NAME -c "hostname" 2>$null).Trim()
Write-Host "Hostname: $hostname"
if ($hostname -match "S$") {
    Write-Host "[PASS] Hostname ends with 'S' (Server)" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] Hostname should end with 'S'" -ForegroundColor Red
    $failed++
}

# 1.8 Check eth1 IP Address
Write-Host "`n[1.8] Checking eth1 IP Address..." -ForegroundColor Magenta
$ethOutput = vagrant ssh $VM_NAME -c "ip addr show eth1 | grep 'inet'" 2>$null
Write-Host $ethOutput
if ($ethOutput -match $IP) {
    Write-Host "[PASS] eth1 IP is $IP" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] eth1 IP mismatch" -ForegroundColor Red
    $failed++
}

#============================================
# SECTION 2: HTTP ROUTING TESTS (from Host)
# ============================================
Write-Host "`n`n[SECTION 2] HTTP Routing Tests (from Windows Host)" -ForegroundColor Yellow
Write-Host "---------------------------------------------------" -ForegroundColor Yellow

# 2.1 Test App 1 (Host: app1.com)
Write-Host "`n[2.1] Testing App 1 (Host: app1.com)..." -ForegroundColor Magenta
$app1Pass = $false
try {
    $r1 = Invoke-WebRequest -Uri "http://$IP" -Headers @{Host="app1.com"} -UseBasicParsing -TimeoutSec 10
    if ($r1.Content -match "Hello from App 1!") {
        Write-Host "[PASS] App 1 -> Correct response" -ForegroundColor Green
        $passed++
        $app1Pass = $true
    } else {
        Write-Host "[FAIL] App 1 -> Content mismatch" -ForegroundColor Red
        $failed++
    }
} catch {
    Write-Host "[FAIL] App 1 -> Connection failed" -ForegroundColor Red
    $failed++
}

# 2.2 Test App 2 (Host: app2.com)
Write-Host "`n[2.2] Testing App 2 (Host: app2.com)..." -ForegroundColor Magenta
$app2Pass = $false
try {
    $r2 = Invoke-WebRequest -Uri "http://$IP" -Headers @{Host="app2.com"} -UseBasicParsing -TimeoutSec 10
    if ($r2.Content -match "Hello from App 2!") {
        Write-Host "[PASS] App 2 -> Correct response" -ForegroundColor Green
        $passed++
        $app2Pass = $true
    } else {
        Write-Host "[FAIL] App 2 -> Content mismatch" -ForegroundColor Red
        $failed++
    }
} catch {
    Write-Host "[FAIL] App 2 -> Connection failed" -ForegroundColor Red
    $failed++
}

# 2.3 Test App 3 (Default - No Host Header)
Write-Host "`n[2.3] Testing App 3 (Default Route)..." -ForegroundColor Magenta
$app3Pass = $false
try {
    $r3 = Invoke-WebRequest -Uri "http://$IP" -UseBasicParsing -TimeoutSec 10
    if ($r3.Content -match "Hello from App3!") {
        Write-Host "[PASS] App 3 (Default) -> Correct response" -ForegroundColor Green
        $passed++
        $app3Pass = $true
    } else {
        Write-Host "[FAIL] App 3 -> Content mismatch" -ForegroundColor Red
        $failed++
    }
} catch {
    Write-Host "[FAIL] App 3 -> Connection failed" -ForegroundColor Red
    $failed++
}

# ============================================
# SECTION 3: FINAL SUMMARY
# ============================================
Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "         VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$total = $passed + $failed

Write-Host "`nTotal Checks: $total"
Write-Host "Passed: $passed" -ForegroundColor Green
if ($failed -eq 0) {
    Write-Host "  Failed: $failed" -ForegroundColor Green
} else {
    Write-Host "  Failed: $failed" -ForegroundColor Red
}

Write-Host "`n----------------------------------------"
Write-Host "CHECKLIST FOR EVALUATION:" -ForegroundColor Yellow
Write-Host "----------------------------------------"

# Final checklist with indicators
$nodePass = $nodeOutput -match "Ready"
$app1ReplicaPass = $deployOutput -match "app-one\s+1/1"
$app2ReplicaPass = $deployOutput -match "app-two\s+3/3"
$app3ReplicaPass = $deployOutput -match "app-three\s+1/1"
$podsPass = $runningPods -eq 5
$svcPass = ($svcOutput -match "app-one-service") -and ($svcOutput -match "app-two-service") -and ($svcOutput -match "app-three-service")
$ingressPass = $ingressOutput -match $IP
$hostnamePass = $hostname -match "S$"
$ethPass = $ethOutput -match $IP

$checks = @(
    @{ Name = "Node Status Ready"; Pass = $nodePass },
    @{ Name = "app-one: 1/1 replicas"; Pass = $app1ReplicaPass },
    @{ Name = "app-two: 3/3 replicas (REQUIRED)"; Pass = $app2ReplicaPass },
    @{ Name = "app-three: 1/1 replicas"; Pass = $app3ReplicaPass },
    @{ Name = "5 pods running"; Pass = $podsPass },
    @{ Name = "All services exist"; Pass = $svcPass },
    @{ Name = "Ingress IP correct"; Pass = $ingressPass },
    @{ Name = "Hostname ends with S"; Pass = $hostnamePass },
    @{ Name = "eth1 IP is $IP"; Pass = $ethPass },
    @{ Name = "HTTP app1.com works"; Pass = $app1Pass },
    @{ Name = "HTTP app2.com works"; Pass = $app2Pass },
    @{ Name = "HTTP default works"; Pass = $app3Pass }
)

foreach ($check in $checks) {
    if ($check.Pass) {
        Write-Host "  [OK] $($check.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [X] $($check.Name)" -ForegroundColor Red
    }
}

Write-Host "`n========================================"
if ($failed -eq 0) {
    Write-Host "  PART 2 COMPLETE - READY FOR EVAL" -ForegroundColor Green
} else {
    Write-Host "  PART 2 INCOMPLETE - FIX FAILURES" -ForegroundColor Red
}
Write-Host "========================================`n" -ForegroundColor Cyan