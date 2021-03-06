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

# Disable warning about local keyword
# shellcheck disable=SC2039

#======================
# CONF_READ
#
# Read and parse a conf file.
#
# The conf file should look like:
#   ```
#   name    Giganticus
#   animal  Octopus (Enteroctopus membranaceus)
#   # Comments on separate lines are OK.
#   name    Astro Chicken
#   animal  Chicken (Gallus gallus)
#   ```
#
# It will stop reading when an already set variable is encountered again, this is the signal that conf has read "one block".
#
# $out_conf_lineno will be updated so the next time you call CONF_READ you will get the next "block".
# Remember to reset all variables first, otherwise it won't read new lines.
# $out_conf_lineno will be set to -1 when no more lines could be read.
#
# Example:
#   local out_conf_lineno=0  # Only done once.
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
#   $out_conf_lineno: should have been declared = 0.
#   $keys: Variable names defined in $2 should prior have been initialized and set to empty, like "local name=".
#
# Returns:
#   0: success
#   1: failure
#
#======================
CONF_READ()
{
    SPACE_SIGNATURE="conffile:1 keys:1"     # shellcheck disable=2034
    SPACE_DEP="PRINT STRING_TRIM"       # shellcheck disable=2034

    local conffile="${1}"
    shift

    local keys="${1}"
    shift

    if [ ! -f "${conffile}" ]; then
        PRINT "Conf file ${conffile} is missing." "error"
        return 1
    fi

    local _lineno=${out_conf_lineno:-0}
    local _currentno=-1
    local line=
    while true; do
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
                    # Key not in list, skip it and continue reading file.
                    continue 2
            done

            if eval "[ \"\${${key}:+set}\" != \"set\" ]"; then
                eval "${key}=\"\${val}\""
            else
                # Do not overwrite a value, it's time to stop.
                break 2
            fi
        done < "${conffile}"
        # If we get here then we have read all the file,
        # we'll signal that we are done by setting the $out_conf_lineno variable to -1.
        out_conf_lineno="-1"
        return 0
    done
    # We come here when a "block" has been read, but there could still be more to come.

    # If this was not declared as local with caller,
    # then it becomes a global variable.
    out_conf_lineno="${_currentno}"
}
