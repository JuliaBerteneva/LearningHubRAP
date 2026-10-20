*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZLH_USER_REL....................................*
DATA:  BEGIN OF STATUS_ZLH_USER_REL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZLH_USER_REL                  .
CONTROLS: TCTRL_ZLH_USER_REL
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZLH_USER_REL                  .
TABLES: ZLH_USER_REL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
