# ABCD XSLT Landingpages
An XSLT Script to generate Dataset Landingpages based on the ABCD File of the dataset

This is a proof of concept for generating dataset landing pages for ABCD data sets based on the ABCD files of the dataset using an XSL Transformation. The transformation is done via an simple php script that calls the SAXON Processor, as the style sheets rely on XSLT 2 features.

Try it for yourself
-------------------

**using a single file**

-   <http://terminologies.gfbio.org/tools/landingpage.php?file=http%3A%2F%2Fterminologies.gfbio.org%2Ftools%2Fresponse.00001.xml>
    -   just replace the `file=` parameter with a URL to your ABCD file (url encoded: <http://www.url-encode-decode.com/>)
    -   or try it without the parameter for a demo file.

**using an archive**

-   <http://terminologies.gfbio.org/tools/landingpage.php?archive=http%3A%2F%2Fbiocase.snsb.info%2Fwrapper%2Fdownloads%2FIBForthopteracoll%2FIBF%2520Monitoring%2520of%2520Orthoptera.ABCD_2.06.zip>
    -   just replace the `archive=` parameter with a URL to your ABCD archive file (url encoded: <http://www.url-encode-decode.com/>)

Features
--------

-   nice overview of all the relevant information about a dataset
-   lists of owners, taxonomic names,
-   bounding box for all GPS coordinates
-   list of all units with links to their landing pages, if the field `abcd:RecordURI` is set
-   caching of HTML output to speed up processing
    -   requires writing rights for the php script to the directory it is executed in or the caching directory specified in the file (see section Setup)
-   support of ABCD archives. The link to the zip files can be handed over via the GET parameter `?archive=`
    -   no limit on the number of units, even if they are spread over several exported files within the archive
    -   for large archives (10.000+ units) this can take a while (10-20 seconds if not cached)
-   Support for ABCD 2.1
    -   Though ABCD 2.06 is still considered to be the default, if this transformation returns an empty result, another attempt is made using another XSLT file for ABCD 2.1 (both XSLT files are identical, except for the name space associated to the namespace prefix `abcd:`, since all of the elements used for the transformation are common between those two formats)

Disadvantages
-------------

-   requires XSLT 2 which is still not supported by most browsers and servers. To do the transformation on the server side, the server needs to have an XSLT 2 processor manually installed. Suggested processor: [Saxon-HE/C](http://www.saxonica.com/saxon-c/index.xml) (warning: it is a bit tricky to install)

Setup
-----

-   save the files `abcd_2.06_dataset_landingpage.xslt`,`abcd_2.1_dataset_landingpage.xslt`  and `landingpage.php` on the server
-   if needed adjust the caching directory (by default *./caching*) and caching time (by default: one week)
-   create the directory specified as the caching directory in `landingpage.php` (*./caching* if not changed in the previous step)
-   make sure the caching directory has writing permission for the user executing the php file. E.g. under default configuration with Apache on Linux this would be `www-data`:

  `sudo chown www-data:www-data caching/`

  `sudo chmod 775 caching/`

Further Ideas
-------------

**in the XSLT file**:

-   show bounding box of coordinates on map using Leaflet
-   preview Images
-   Use preferred Identification for Unit List, currently it uses the first
-   add section about IPR/License

**in the php file**:

-   support for locally stored abcd files

Please report any bugs, issues or improvement ideas at the [Github Issues Page](https://github.com/gfbio/ABCD_XSLT_Landingpages/issues).
