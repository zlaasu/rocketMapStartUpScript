<html>
<head>
    <title>Title</title>
<style type="text/css">
	table.table-style-two {
		font-family: verdana, arial, sans-serif;
		font-size: 11px;
		color: #333333;
		border-width: 1px;
		border-color: #3A3A3A;
		border-collapse: collapse;
	}
 
	table.table-style-two th {
		border-width: 1px;
		padding: 8px;
		border-style: solid;
		border-color: #517994;
		background-color: #B2CFD8;
	}
 
	table.table-style-two tr:hover td {
		background-color: #DFEBF1;
	}
 
	table.table-style-two td {
		border-width: 1px;
		padding: 8px;
		border-style: solid;
		border-color: #517994;
		background-color: #ffffff;
	}
</style>
</head>
<body>

<?php
$servername = "localhost";
$username = "login";
$password = "pass";

// Create connection
$conn = new mysqli($servername, $username, $password);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
//echo "Connected successfully<br><br>";

function get_string_between($string, $start, $end){
    $string = ' ' . $string;
    $ini = strpos($string, $start);
    if ($ini == 0) return '';
    $ini += strlen($start);
    $len = strpos($string, $end, $ini) - $ini;
    return substr($string, $ini, $len);
}

function getPokemonCount($conn, $db, $avg) {
    $sql = "SELECT count(encounter_id) as count  FROM " . $db . ".pokemon WHERE disappear_time > CONVERT_TZ(now(),'+02:00','+00:00')";
    //echo $sql;
    foreach ($conn->query($sql) as $row) {
	if ( $row['count'] < $avg ) { 
	  echo ' <b><font color="red">POSSIBLE SB!!!</font></b>'; 
	}
        echo " count: " . $row['count'] . " / avg: " . $avg . "<br>";
    }

}

function getStatus($conn,$db,$avg) {
    $sql = 'SELECT * FROM '.$db.'.mainworker';
    echo "<b>" . $db . "</b><br>";

    getPokemonCount($conn, $db ,$avg);

    echo "<table class='table-style-two'>";
    echo "<thead><tr><td>Worker</td><td>Initial scan</td><td>TTH found</td><td>Spawns reached</td></tr></thead><tbody>";
    foreach ($conn->query($sql) as $row) {
	echo "<tr>";
        echo "<td>" . $row['worker_name'] . "</td>";
        echo "<td>" . get_string_between($row['message'], "Initial scan: " , "%") . "</td>";
        echo "<td>" . get_string_between($row['message'], "TTH found: " , "%") . "</td>";
        echo "<td>" . get_string_between($row['message'], "Spawns reached: " , "%") . "</td>";
	echo "</tr>";
    }
    echo "</tbody></table><br>";
}


getStatus($conn, "debRocketMap", 500);
getStatus($conn, "gowRocketMap", 1300);
getStatus($conn, "podRocketMap", 2950);
getStatus($conn, "zyrRocketMap", 500);
getStatus($conn, "szcRocketMap", 1500);
getStatus($conn, "lubRocketMap", 3000);
getStatus($conn, "wawRocketMap", 7000);

?>

</body>
</html>

