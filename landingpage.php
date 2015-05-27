<?php
	ini_set('error_reporting', E_ALL);
	header('Content-type: text/html; charset=utf-8');
	// get XML file to transform
	$file = $_GET['file'];
	
	//use example file if no file is provided
	if(!$file){
		$file = "abcd_example_valid.xml";
	}

	$xslFile = "abcd_dataset_landingpage.xslt";
    
    //Use the Saxon CE processor, to get XSLT2 support. 
    //This needs to be installed separatly, see //www.saxonica.com/saxon-c/index.xml for details
	$proc = new SaxonProcessor();
	
	$proc->setSourceFile($file);
	$proc->setStylesheetFile($xslFile);
			  
	$result = $proc->transformToString();               
	if($result != null) {               
		echo $result;
	} else {
	   echo "an error occurred, see log for details";
	}
	$proc->clearParameters();
	$proc->clearProperties();            
?>
