*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data _null_;

  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
        data _null_;
          rc=dcreate("parent","d:/");
          call symputx("folder","parent");
        run;quit;
    '));
   end;

   do dsns='class', 'classfit', 'cars';
     call symputx('dsn',dsns);

     rc=dosubl('
       libname xmlout xml "d:\&folder.\&dsn..xml" xmltype=generic;
          data xmlout.&dsn.;
             set sashelp.&dsn.;
          run;quit;
       libname xmlout clear;
     ');
   end;

run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|
;

proc datasets lib=work kill;
run;quit;
%symdel memnames folder dsn /nowarn;
data _null_;

    * get list of xml files in folder;
   if _n_=0 then do;
     %let rc=%sysfunc(dosubl('
         filename dop "d:/parent";
         data contents;
             length memnames $200 memname $44;
             retain memnames "";
             fid=dopen("dop");
             memcount=dnum(fid);
             do i=1 to memcount;
                 memname=quote(scan(dread(fid,i),1,"."));
                 memnames=catx(",",memname,memnames);
             end;
             call symputx("memnames",memnames);
             call symputx("folder",parent);
             rc=dclose(fid);
         run;quit;
         %put &=memnames;
     '));
   end;

   length dsns $44; * important because length detemined by fist element;
   do dsns=&memnames;

     call symputx('dsn',dsns);

     rc=dosubl('
       libname xmlinp xml "d:\&folder.\&dsn..xml" xmltype=generic;
          proc sql;
            create
              table &dsn. as
            select
              *
            from
              xmlinp.&dsn.
          ;quit;
       libname xmlinp clear;
     ');

    if symget('sqlobs')='0' then do;
       putlog "stopping because " dsn " is empty";
       stop;
    end;

   end;

run;quit;

