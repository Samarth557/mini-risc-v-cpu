proc fetch_tns {} { #we only want paths with negative slack, so max_slack flag set to 0  
    set TNS 0.0 
    foreach slack [get_db [report_timing -collection -max_paths 100000 -max_slack 0] .slack] { #loop to sum paths from database
        set TNS [expr {$TNS + $slack}]
    }
    return $TNS
}