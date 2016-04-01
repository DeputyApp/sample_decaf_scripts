# Save this script as Record Validation for Comment
`<cwa_checkrole role="System Administrator" assign="isAdmin"/>`
`<cwa_checkrole role="Supervisor" assign="isSupervisor"/>`
`<cwa_checkrole role="Location Manager" assign="isLocManager"/>`
if CurrentRecord.Orm is "DeputecMemo" and !isAdmin  and !isSupervisor and !isLocManager
  return { field: "Comment", message: "Commenting is disabled."}
else
  return 0
