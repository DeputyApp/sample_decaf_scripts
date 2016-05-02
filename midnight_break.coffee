###########################################################################
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
###########################################################################


############################################################################
# Script to Break a shift that was running past midnight and starting it again
#
# Save this script as a DeXML CRON Script. More info: http://api-doc.deputy.com/Dexml_Scripts/Overview
#
# TODO: this is execute in the main timezone of workplace. Needs slight modification if you are in
# multi timezone install
############################################################################
sstrTodayYMD = dateprint({format:'Y-m-d'})
intNowTs = unixtime({})

strMidNightFirstCron = dateprint({format:'Gis'})

# Cron runs ONCE every 15 minutes. Only execute in the first 15 minutes of the night
if strMidNightFirstCron > '01459'
  return "After midnight cron execution #{strMidNightFirstCron}"

log({message: "midnight_break : RUNNING" , system:1})

actual_midnight = intNowTs - (dateprint({format:'i'}) * 60 ) - dateprint({format:'s'}) 
  

 
# fetch the InProgress Timesheet whose EndTime is lessEqual after Now
`<db_fetch system="Timesheet" assign="objTimesheetArray">
  <db_condition>
    <db_compare column="EndTime" function="ge"><atom var="intNowTs" /></db_compare>
    <db_compare column="IsInProgress" function="eq">1</db_compare>
  </db_condition>
</db_fetch>`
 
 


  
 
# loop the timesheet to auto end 
for objTimesheet in objTimesheetArray
  intReferencedRosterId = objTimesheet.Roster
  intEmployeeId = objTimesheet.Employee
  objMBs = objTimesheet.MealbreakSlots #  smarts required but not doing anything..
  intOpunitId = objTimesheet.OperationalUnit
  intTimesheetId = objTimesheet.Id
  intStartTime = objTimesheet.StartTime
  intLenghtSoFar = intNowTs - intStartTime
  intMealbreakMinute = 0
  if(intReferencedRosterId)
    `<db_fetch system="Roster" assign="objReferencedRoster">
      <db_condition>
        <db_compare column="Id" function="eq"><atom var="intReferencedRosterId" /></db_compare>
      </db_condition>
    </db_fetch>`
    if(objReferencedRoster && objReferencedRoster[0])
      intMealbreakMinute = dateprint({format:'G', input:objReferencedRoster[0].Mealbreak})*60 + dateprint({format:'i', input:objReferencedRoster[0].Mealbreak})
  
  if intMealbreakMinute > intLenghtSoFar
     intMealbreakMinute = 0
  
  #end now
  objPostEnd = {intTimesheetId: intTimesheetId, intMealbreakMinute: intMealbreakMinute}
  log({message: "midnight_break stop : intEmployeeId = #{intEmployeeId} - intMealbreakMinute = #{intMealbreakMinute}" , system:1})
  deputy_rest({url:"supervise/timesheet/end", method:"POST" , post: objPostEnd})
  # put it back to midnight
  objPostEnd = {EndTime:actual_midnight}
  newEnd = deputy_rest({url:"resource/Timesheet/#{intTimesheetId}", method:"POST" , post: objPostEnd})
  log({message: "midnight_break newEnd" , obj:newEnd , system:1})

  
  # start again
  log({message: "midnight_break start: intEmployeeId = #{intEmployeeId} - intOpunitId = #{intOpunitId}" , system:1})
  objPostStart = {intOpunitId: intOpunitId, intEmployeeId: intEmployeeId}
  newTS = deputy_rest({url:"supervise/timesheet/start", method:"POST" , post: objPostStart})
  # set the start time as midnight
  objPostStart = {StartTime:actual_midnight}
  newStart = deputy_rest({url:"resource/Timesheet/#{newTS.Id}", method:"POST" , post: objPostStart})
  log({message: "midnight_break newStart" , obj:newStart , system:1})
