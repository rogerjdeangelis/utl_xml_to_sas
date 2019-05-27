# utl_xml_to_sas
Covert all SAS created  XML files in a folder to SAS datasets
    T1006810 SAS Forum: How to Input All Files in a Folder? (covert all xml files in a folder to SAS datasets)

    see
    https://goo.gl/1L9eP7
    https://communities.sas.com/t5/General-SAS-Programming/How-to-Input-All-Files-in-a-Folder/m-p/379514

      WORKING CODE

           DOSUBL (compile time ) if _n_=0)

                 * get quoted list of xml files in parent folder;

                 fid=dopen("d:/parent");
                 memcount=dnum(fid);
                 do i=1 to memcount;
                     memname=quote(scan(dread(fid,i),1,"."));
                     memnames=catx(",",memname,memnames);
                 end;
                 call symputx("memnames",memnames);
                 call symputx("folder","parent");

           MAINLINE
                do dsns=&memnames;
                   call symputx('dsn',dsns);
           DOSUBL
               libname xmlinp xml "d:\&folder.\&dsn..xml" xmltype=generic;
                  data &dsn.;
                     set xmlinp.&dsn.;
                  run;quit;
               libname xmlinp clear;
           MAINLINE
               if symget('sqlobs')='0' then do;
                  putlog "stopping because " dsn " is empty";
                  stop;

    HAVE
    ====

        d:/parent/
            class.xml
            iris.xml
            cars.xml

    WANT
    ====
       work.class
       work.iris
       work.cars

