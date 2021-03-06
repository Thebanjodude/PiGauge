<?php

$chart_array = array(
	'Your chart here',
	'The noise level in the room',
	'Ben\'s Love/Hate Relationship with Vi',
	'Morale on a payday',
	'Project mood guage'
	) ;

$mood_array = array(
	array ('This is so cool!','20'),
	array ('Python Rocks!','35'),
	array ('Python Stinks','50'),
	array ('My Pi just died','70'),
	array ('PHP?','90')
	);

$hide_form=True ;

function body( $hide_form, $chart_array, $mood_array){
	if (! $hide_form) {
		if (get_status($servo_status) == 0) print_status($servo_status, $chart_array) ;
		echo '<hr>';
		print_form($chart_array, $mood_array);
	}else{ 
		$command = "python MoveServos.py -c " . $_POST['ChartNum_Write'] . " -p " . $_POST['ChartPos_Write'];
			exec($command,$set_chart_output,$set_chart_exit_code);
		if ($set_chart_exit_code > 0) { 
			echo 'Failed to run python script...'; 
		} else {
			echo '<head><meta http-equiv="refresh" content="3"></head>' . "Changing chart ". $chart_array[$_POST['ChartNum_Write']-1] ." to $_POST[ChartPos_Write] <p>";
		}
		echo '<a href="'. $_SERVER['PHP_SELF'] .'">Return to front page</a>';
	}
}


function debug($var){
	print '<pre>';
	var_dump($var);
	print '</pre>';
}


function foot(){
	print '</body></html>';
}


function get_status( &$get_servo_status ){
	exec('python MoveServos.py -a 2>&1',$get_servo_status,$exit_code);
	if ($exit_code> 0){
		print "Failed to run python script";
		return 1;
	}else{
		return 0;
	}
}


function head( $refresh ){
	print '<html>';
	// check to see if we need to add the page refresh html
	if ( $refresh ) print '<head><meta http-equiv="refresh" content="3"></head>' ;
	print '<body>' ;
}


function print_form( $chart_array, $mood_array ){
	for ($y=1; $y<=4; $y++) {
		$chart_name = $chart_array[$y-1] ;
		echo '<form action="'. $_SERVER['PHP_SELF'] .'"method="post">';
		echo "<input type=\"hidden\" name=\"ChartNum_Write\" value=\"$y\">$chart_name = <input type=\"text\" name=\"ChartPos_Write\" /><input type=\"submit\"/></form>";
	}
	echo '<form action="'. $_SERVER['PHP_SELF'] .'"method="post">';
	echo '<input type="hidden" name="ChartNum_Write" value="5">'. $chart_array[4] .' = <select name="ChartPos_Write">';
	for ($z=0; $z<5; $z++) { $mood=$mood_array[$z][0]; $mood_spot=$mood_array[$z][1]; echo "<option value=\"$mood_spot\">$mood</option>";}
	echo '</select><input type="submit" /></form>'; 
}


function print_status($input, $chart_name){
	for ($x=0; $x<=4; $x++) {
		print $chart_name[$x] ." is at ". $input[$x] ."%<br>";
	}
}


/* hide the form if it has just been filled out, no need to see it a second time */
if ((empty($_POST['ChartNum_Write'])) 
	|| ($_POST['ChartPos_Write'] < 0) 
	|| ($_POST['ChartPos_Write'] > 100) ) $hide_form=False ;

/* HTML generation follows */
head( $hide_form );
body( $hide_form, $chart_array, $mood_array);
foot();
?>

