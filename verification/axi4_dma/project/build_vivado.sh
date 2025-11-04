#!/bin/bash
rm -rf project
vivado -source project.tcl -nolog -nojournal -mode batch
