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
# Note : this does a dummy print of all the employees and their realtime costing.
#        feel free to modify it to dump json for your scripts
#


-->`


`<db_fetch system="Timesheet" assign="tss">
    <db_condition>
     <db_compare column="IsInProgress" function="eq">1</db_compare>    
   </db_condition>
   <db_join objname="EmployeeObject"/>
  </db_fetch>`


empRate = []
totalWage = 0
totalSale = 0
timenow = dateprint({format:"U"})
earliest = timenow - 86400 # one day ago
log({message:"timenow #{timenow}"})
for timesheet in tss
  `<cwa_getshiftcost shift="$timesheet" return="breakdown" assign="breakdown"/>`
  log({message:"breakdown" , obj:breakdown})
  name = timesheet.EmployeeObject.DisplayName
  empRate[name] = {sales:0 , wage: 0}
  earliest = timesheet.StartTime if earliest > timesheet.StartTime
  for b in breakdown
    totalTime = (timenow - b.start_time)/3600
    log({message:"totalTime #{timenow} #{b.start_time} totalTime = #{totalTime} "})
    t = totalTime * b.pay_condition.HourlyRate
    empRate[name].wage = empRate[name].wage + t
  totalWage = totalWage + empRate[name].wage

# get sales total
`<db_fetch system="SalesData" assign="sales">
   <db_condition>
    <db_compare column="Timestamp" function="ge"><atom var="earliest"/></db_compare>    
 </db_condition>
 <db_join objname="EmployeeObject"/>
 
</db_fetch>`    

for sale in sales
  name = sale.EmployeeObject.DisplayName
  if index_exists({var:empRate , index:name})
    empRate[name].sales = empRate[name].sales + sale.SalesAmount
  totalSale = totalSale + sale.SalesAmount
  
                  


log({message:"Total ret" , obj:empRate})
ret = "<pre>" & sprintf({format:"%30s %8s %8s <br>" , input1:"     " , input2:"Sales" , input3: "Wages"}) 
ret = ret & "--------------------------------------------------------------<br>"
  
for emp in empRate
  s = sprintf({format:"%09.2f" , input:emp.sales})
  w = sprintf({format:"%09.2f" , input:emp.wage})
  ret = ret & sprintf({format:"%30s %8.2f %8.2f <br>" , input1:index , input2:emp.sales , input3:emp.wage}) 
  
ret = ret & "--------------------------------------------------------------<br>"
ret = ret & sprintf({format:"%30s %8.2f %8.2f <br>" , input1:"Total" , input2:totalSale , input3: totalWage}) 

return ret  
