**FREE
ctl-opt nomain;

/include 'commands.RPGLEINC'

//--------------------------------------------------------------------
// Execute a CL Command
//--------------------------------------------------------------------
Dcl-Proc execCommand export;
    Dcl-PI *N;
        commandString  Char(32702) CONST OPTIONS(*VARSIZE);
    End-PI;
    
    monitor;
        qcmdexc( %trim(commandString) : %len(commandString) );
    on-error;
    endMon;    
    
    Return;

End-Proc;