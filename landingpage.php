<?php
	ini_set('error_reporting', E_WARNING);
	$cache_dir = "./cache"; //without trailing slash
	
	//$caching_time_in_seconds = 60 * 2; //debug: 2 minutes
	$caching_time_in_seconds = 60 * 60 * 24 * 7;
	//                         sec  min  hour day
	
	//recursively remove an entire directory tree
	//copied from http://stackoverflow.com/questions/3349753/delete-directory-with-files-in-it/14531691#14531691
	function delTree($dir) {
		$files = array_diff(scandir($dir), array('.','..'));
		foreach ($files as $file) {
			(is_dir("$dir/$file")) ? delTree("$dir/$file") : unlink("$dir/$file");
		}
		return rmdir($dir);
	}	
	
	function cleanUp($cache_dir, $caching_time_in_seconds){
		//clean up outdated caching directories	
		$elements_in_cache_dir = scandir($cache_dir);
		$individual_cache_directories = array();
		//go through cache dir
		foreach ($elements_in_cache_dir as &$element_in_cache_dir) {
			//only select folders whose names are md5sum results
			if(preg_match("/^[a-f0-9]{32}$/",$element_in_cache_dir)==1){
				if(is_dir($cache_dir."/".$element_in_cache_dir)){
					$individual_cache_directories[] = $cache_dir."/".$element_in_cache_dir;
				}
			}
		}
		
		//check the individial cache directories
		foreach ($individual_cache_directories as &$individual_cache_dir) {
			$elements_in_individual_cache_dir = scandir($individual_cache_dir);
			//the directory is only allowed to have one file: the output.html. scandir will also deliver the links for the current and the parent directory
			if(count($elements_in_individual_cache_dir)==3 
				&& $elements_in_individual_cache_dir[0]=="."
				&& $elements_in_individual_cache_dir[1]==".."
				&& $elements_in_individual_cache_dir[2]=="output.html" ){
				
				$output_file = $individual_cache_dir ."/". "output.html";
				//if the file is too old, remove it. Add 1 minute of additional grace period to avoid concurrency problems
				if(filemtime($output_file) < ( time() - ($caching_time_in_seconds - 60) ) ) { 
					unlink($output_file);
					//remove empty directory as well
					rmdir($individual_cache_dir);
				}				
			}
		}
	}
	
	header('Content-type: text/html; charset=utf-8');
	// get XML file to transform
	$file = $_GET['file'];
	$archive = $_GET['archive'];
	
	$useZip = false;
	$cache_token = "";
	if($file && preg_match("/^https?:\/\//i",$file)==1){
		$cache_token = md5("file".$file);
	}else{
		if($archive && preg_match("/^https?:\/\/.*\.zip/i",$archive)==1){
			//a zip file is handed over as archive parameter
			$useZip = true;
			$cache_token = md5("archive".$archive);
		}else{
			//use example file if no file is provided or file doesn't start with http or https
			$file = "abcd_example_valid.xml";
			$cache_token = md5("example_file".$file);
		}
	}
	
	//generate temporary dir
	$current_cache_dir = $cache_dir."/".$cache_token."/";
	if(!file_exists($current_cache_dir)){
		$successful = mkdir($current_cache_dir,0755,true);
		if(!$successful){
			echo "The landingpages.php script either needs to be run in a directory where it has write access or the directory specified ".
				  "in \$cache_dir (currently '".$cache_dir."') needs to exist and the script needs to have write access for it.";
			http_response_code(500);
			return;
		}
	}	
	
	//the file in which the output will be generated
	$output_file = $current_cache_dir."output.html";
	//check if output file already exists and if it is still within the cache limit
	if (( file_exists($output_file) && filemtime($output_file) > ( time() - $caching_time_in_seconds ) )) { 
		//if the cached version is still valid, return the content of this file
		echo file_get_contents($output_file);
		//remove outdated caching files and directories
		cleanUp($cache_dir, $caching_time_in_seconds);
		return;
	}
	
	//either no cached version exists or the file is not too old
	//remove the file if it exists
	if(file_exists($output_file)){
		unlink($output_file);
	}
	
	if($useZip){
		$joined_content = $current_cache_dir."joined_content.xml";
		
		//usually this file should be deleted, but this is to ensure there are no problems if the line in charge
		//deleting it at the end of this file is commented for debugging purposes.
		if(file_exists($joined_content)){
			unlink($joined_content);
		}
		
		$local_zip = $current_cache_dir."file.zip";
		$content = file_get_contents($archive);
		if($content == null){
			echo "Could not load content from '$archive'. Please make sure the URL is properly urlencoded!";
			rmdir($current_cache_dir);
			http_response_code(500);
			return;
		}
		file_put_contents($local_zip, $content);  
		
		$unzip_dir = $current_cache_dir."unzip/";
		mkdir($unzip_dir);
		
		$zip = new ZipArchive;
		if ($zip->open($local_zip) === TRUE) {
			$zip->extractTo($unzip_dir);
			$zip->close();
		}
		
		//go through files in $unzip_dir and only select *.xml files
		//subfolders are ignored
		$files_in_zip = scandir($unzip_dir);
		$local_files = array();
		foreach ($files_in_zip as &$file_in_zip) {
			if(preg_match("/\.xml$/i",$file_in_zip)==1){
				$local_files[] = $file_in_zip;
			}
		}
				
		if(count($local_files)==1){
			//there is only one file
			//extract content from file
			$file_content = file_get_contents($unzip_dir.$local_files[0]);
			//write content to joined content file, without modification
			file_put_contents($joined_content,$file_content);
		}else{
			$size = count($local_files);
			//go through all xml files 
			for($i = 0; $i<$size; $i++){
				$local_file = $local_files[$i];
				$is_first = false;
				if($i==0){
					$is_first = true;
				}
				$is_last = false;
				if($i==$size-1){
					$is_last = true;
				}
				
				$file_content = file_get_contents($unzip_dir.$local_file);
								
				if($is_first){
					//only remove the last part for the first file, keep the beginning
					preg_match("/^(.*)<\/([a-zA-Z_][a-zA-Z_0-9\-\.]+:)?Units>/m",$file_content,$matches);
					$file_content = $matches[1];
				}else if($is_last){
					//remove only the beginning from the last file, keep the end 
					preg_match("/<([a-zA-Z_][a-zA-Z_0-9\-\.]+:)?Units>(.*)$/m",$file_content,$matches);
					$file_content = $matches[2];
				}else {
					//for some strange reason, doing a replacement combining the two above cases (i.e. removing the first part until and including <abcd:Units> 
					//and the last part starting from and including </abcd:Units>) will result in an empty result set. So using the caputure group is a slower 
					//but at least working alternative.
					preg_match("/<([a-zA-Z_][a-zA-Z_0-9\-\.]+:)?Units>(.*)<\/([a-zA-Z_][a-zA-Z_0-9\-\.]+:)?Units>/m",$file_content,$matches);
					$file_content = $matches[2];
				}
				
				//this used to work, but ereg_replace is deprecated and also slower than preg_replace
				//
				//if(!$is_first){
				//	//$file_content = ereg_replace("^.*<abcd:Units>",'',$file_content);
				//}
				//if(!$is_last){
				//	//$file_content = ereg_replace("</abcd:Units>.*$",'',$file_content);
				//}
				file_put_contents($joined_content,$file_content."\n",FILE_APPEND);
			}
		}
		//remove the unzip folder (it is not needed any more)
		delTree($unzip_dir);
		
		//remove the zip file (it is not needed any more)
		unlink($local_zip);
		
		//hand over the joined content as the file to process with the XSLT
		$file = $joined_content;
	}
	
	$xslFile206 = "abcd_2.06_dataset_landingpage.xslt";
	$xslFile21  = "abcd_2.1_dataset_landingpage.xslt";
    
	//Use the Saxon CE processor, to get XSLT2 support. 
	//This needs to be installed separatly, see //www.saxonica.com/saxon-c/index.xml for details
	$proc = new SaxonProcessor();
	
	$proc->setSourceFile($file);
	$proc->setStylesheetFile($xslFile206);
			  
	$result = $proc->transformToString();               
	if($result != null) { 
		if($result == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"){
			$proc = new SaxonProcessor();
	
			$proc->setSourceFile($file);
			$proc->setStylesheetFile($xslFile21);
			  
			$result = $proc->transformToString();   
			if($result == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"){
				echo "Transformation returned an empty result. This could be because the file is empty or because it is not in the ABCD 2.06 or 2.1 format";
				http_response_code(500);
			}
		}
		file_put_contents($output_file,$result);
		echo $result;
	} else {
		echo "An error occurred doing the XSL Transformation. This could be, because the source XML file is not valid or in the wrong format. See log for details.";
		http_response_code(500);
	}
	
	if($useZip){
		//removed the joined xml file, to save space on the drive
		unlink($file);
	}
	$proc->clearParameters();
	$proc->clearProperties();  
	
	//remove outdated caching files and directories
	cleanUp($cache_dir, $caching_time_in_seconds);

?>