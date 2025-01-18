package require Tk

# Initialize variables
set total_questions 0
set correct_answers 0
set has_answered 0
variable correct_answer

set cidr_to_subnet {
    24 {255.255.255.0 256}
    25 {255.255.255.128 128}
    26 {255.255.255.192 64}
    27 {255.255.255.224 32}
    28 {255.255.255.240 16}
    29 {255.255.255.248 8}
    30 {255.255.255.252 4}
    31 {255.255.255.254 2}
    32 {255.255.255.255 1}
}

proc generate_question {} {
    global correct_answer
    global cidr_to_subnet
    set cidr [expr {int(rand() * 9) + 24}]

    set details [dict get $cidr_to_subnet $cidr]
    set subnet_mask [lindex $details 0]

    set correct_answer $subnet_mask
    return $cidr
}

proc generate_choices {correct} {
    global cidr_to_subnet
    set choices [list $correct]

    while {[llength $choices] < 5} {
        set cidr [expr {int(rand() * 9) + 24}]
	set details [dict get $cidr_to_subnet $cidr]
	set subnet_mask [lindex $details 0]
	set partitions [lindex $details 1]

	if {$subnet_mask ni $choices} {
            lappend choices $subnet_mask
        }
    }
    return $choices
}

proc shuffler {a b} {

    set x [expr {int(rand() * 10)} - 5]
    set y [expr {int(rand() * 10)} - 5]

    return $y - $x
}

proc update_labels {} {
    global total_questions correct_answers lbl_stats
    .lbl_stats configure -text "Total: $total_questions, Correct: $correct_answers"
}

proc next_question {frame lbl_question} {
    global total_questions correct_answer has_answered

    set has_answered 0
    incr total_questions
    set cidr [generate_question]
    .lbl_question configure -text "What is subnet for /$cidr?"
    .lbl_feedback configure -text ""

    # Clear previous choices and generate new ones
    foreach widget [winfo children $frame ] {
        destroy $widget
    }

    set choices [generate_choices $correct_answer]
    set choices_shuffle [lsort -command shuffler $choices]
    set i 0
    foreach choice $choices_shuffle {
	incr i
        button $frame.btn$i -text $choice -command "check_answer $choice"
        pack $frame.btn$i -side top -fill x
    }

    update_labels
}

proc check_answer {choice} {
    global correct_answer correct_answers lbl_feedback has_answered

    if {$choice == $correct_answer} {

	if {!$has_answered} {
	    incr correct_answers
	}
        .lbl_feedback configure -text "Correct!" -fg green
    } else {
        .lbl_feedback configure -text "Wrong! The correct answer is $correct_answer." -fg red
    }
    set has_answered 1
    update_labels
}

# Create the main application window
wm title . "Cidr Practice"

# Question label
label .lbl_question -text ""
pack .lbl_question -padx 10 -pady 10

# Choices frame
frame .frame_choices
pack .frame_choices -padx 10 -pady 10 -fill x

# Feedback label
label .lbl_feedback -text "" -fg blue
pack .lbl_feedback -padx 10 -pady 10

# Stats label
label .lbl_stats -text "Total: 0, Correct: 0"
pack .lbl_stats -padx 10 -pady 10

# Next button
button .btn_next -text "Next" -command "next_question .frame_choices .lbl_question"
pack .btn_next -padx 10 -pady 10

set choices [generate_choices {a}]
set x 0
foreach choice $choices {
    incr x
    button .frame_choices.btn$x -text $choice -command "check_answer $choice"
    pack .frame_choices.btn$x -side top -fill x
}

# Start the first question
next_question .frame_choices .lbl_question

# Start the Tk event loop
#tk::MainLoop;
