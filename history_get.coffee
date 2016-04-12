`<!--
#
# Copyright (c) 2011 Deputy.com. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, is NOT permitted
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
#

# Usage: Save this as history_get (script id) and type (Executable via SOAP/REST)
# Test from JS console using : $.post("/api/v1/execdexml/history_get" , JSON.stringify({input:{system:"Employee" , id:1}}) , _client_log)

# Parameters To this Script
#    input:  system:id


-->`

payload = input

return {err:"payload not given!"} if !payload

# check that you are an admin!
me = deputy_rest({url:"me", method:"GET"})
permissions = me.Permissions

return {err:"You do not have admin access"} if !array({input:"ADMINISTRATOR", function:"in_array", arg1:$permissions})
 
strSystem = payload.system
strId = payload.id


#somehow I can't assign this coming as an array?
`<cwa_get_history  system="$strSystem"  id="$strId" />`
