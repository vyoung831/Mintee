# Business Rules
This document specifies business rules that govern Mintee's entities

# Task
| BR code | Entity | Entity |
|-|-|-|
| Task-1 | Task | A Task's taskType can only be one of the following values: <ul> <li/> Recurring <li/> Specific </ul> |
| Task-2 | Task | If a Task's taskType is recurring, startDate and endDate must be non-nil. |
| Task-3 | Task | If a Task's taskType is recurring, targetSets must contain at least one TaskTargetSet. |
| Task-4 | Task | If a Task's taskType is specific, instances must contain at least one TaskInstance. |
| Task-5 | Task | A Task's name must be unique. |
| Task-6 | Task | If a Task's taskType is recurring, endDate must be later than or equal to startDate. |