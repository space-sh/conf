#
# Copyright 2017 Blockie AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

clone string

#======================
# CONF_READ
#
# Read and parse a conf file.
#
# The conf file should look like:
#   name    Giganticus
#   animal  Octopus (Enteroctopus membranaceus)
#   # Comments on seperate lines are OK.
#   name    Speedy Rooster
#   animal  Chicken (Gallus gallus)
#
# It will stop reading when an already set
# variable is encountered again, this is the
# signal that conf has read "one block".
#
# $conf_lineno will be updated so the next
# time you call CONF_READ you will get the next
# "block". Remember to reset all variables first,
# otherwise it won't read new lines.
#
# Example:
#   local conf_lineno=0  # Only done once.
#   local name=
#   local animal=
#   CONF_READ "/tmp/my.conf" "name animal"
#   echo "${name} is a ${animal}."
#
#   # Read next block
#   local name=
#   local animal=
#   CONF_READ "/tmp/my.conf" "name animal"
#   echo "${name} is a ${animal}."
#
# Parameters:
#   $1: file path
#   $2: variable names allowed
#
# Expects:
#   $conf_lineno: should have deen declared = 0.
#   $keys: Variable names defined in $2 should
#       prior have been initialized and set to
#       empty, like "local name=".
#
# Returns:
#   0: success
#   1: failure
#
#======================
CONF_READ()
{
    SPACE_SIGNATURE="conffile keys"
    SPACE_CMDDEP="PRINT"

    local conffile="${1}"
    shift

    local keys="${1}"
    shift

    if [ ! -f "${conffile}" ]; then
        PRINT "Conf file ${conffile} is missing." "error"
        return 1
    fi

    local _lineno=${conf_lineno:-0}
    local _currentno=-1
    local line=
    while IFS='' read -r line; do
        _currentno="$((_currentno + 1))"
        if [ "${_currentno}" -lt "${_lineno}" ]; then
            # Burn some lines
            continue
        fi
        # See if this line is anything good.
        STRING_TRIM "line"
        if [ "${line##\#*}" = "" ]; then
            # Is comment line.
            continue
        fi
        local val="${line#*[\ ]}"
        local key="${line%%${val}}"
        STRING_TRIM "val"
        STRING_TRIM "key"
        # Check if the key is in the list.
        local _okkey=
        while true; do
            for _okkey in ${keys}; do
                if [ "${_okkey}" = "${key}" ]; then
                    break 2
                fi
            done
                continue 2
        done

        if eval "[ \"\${${key}:-unset}\" = \"unset\" ]"; then
            eval "${key}=\"\${val}\""
        else
            # Do not overwrite a value, it's time to stop.
            break
        fi
    done < "${conffile}"

    # If this was not declared as local with caller,
    # then it becomes a global variable.
    conf_lineno="${_currentno}"
}
