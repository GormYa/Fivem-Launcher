<?php
$servername     = "127.0.0.1"; // mysql server adresi
$username       = "root"; // mysql kullanici adi
$password       = "pass"; // mysql parolasi
$dbname         = "database"; // mysql veritabani adi
$use_cloudflare = false; // PHP dosyalari cloudflare arkasinda calisacaksa (domain uzerinden) burayi true yapin
$use_whitelist  = false; // Whitelist icin LauncherStatuses tablosunu kullanacaksaniz burayi true yapin

if (!isset($_GET['steamid'])){
	die("-2");
}

if (!isset($_GET['durum'])){
	die("-2");
}

if ($_GET['durum'] != '-1' && $_GET['durum'] != '0' && $_GET['durum'] != '1'){
	die("-2");
}

$conn = new mysqli($servername, $username, $password, $dbname);
if (mysqli_connect_errno()) {
    die("-2");
}

if ($stmt = $conn->prepare("SELECT login_date, ip_address, status FROM LauncherStatuses WHERE steamid=? LIMIT 1")) {
	$stmt->bind_param("s", $_GET['steamid']);
	$stmt->execute();
	$stmt->bind_result($login_date, $ip_address, $status);
	$stmt->fetch();
	$stmt->close();
	
	$ip = $_SERVER['REMOTE_ADDR'];
	if ($use_cloudflare){
		$ip = $_SERVER['HTTP_CF_CONNECTING_IP'];
	}
	
	if (!isset($status)){
		if ($use_whitelist){
			echo "-3";
		} else {
			$query = $conn->prepare("INSERT INTO LauncherStatuses (`steamid`, `login_date`, `ip_address`, `status`) VALUES (?, NOW(), ?, ?)");
			$query->bind_param('sss', $_GET['steamid'], $ip, $_GET['durum']);
			$query->execute();
			$query->close();
			
			echo $_GET['durum'];
		}
	}
	else {
		if ($status == -1) { // eger oyundaysa ip adresini degistirmiyoruz ki, 2 kisi ayni anda giremesin
			$query = $conn->prepare("UPDATE LauncherStatuses SET login_date=NOW(), status=?");
			$query->bind_param('s', $_GET['durum']);
			$query->execute();
			$query->close();	
		} else {
			$query = $conn->prepare("UPDATE LauncherStatuses SET login_date=NOW(), ip_address=?, status=?");
			$query->bind_param('ss', $ip, $_GET['durum']);
			$query->execute();
			$query->close();
		}
		
		echo $_GET['durum'];
	}
}

mysqli_close($conn);
?>