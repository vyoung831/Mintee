# Business Rules
This document specifies business rules that govern how Mintee stores data.

1. [Model objects](#model-objects)
    1. [Analysis](#analysis)
    1. [Task](#task)
    1. [Tag](#tag)
    1. [TaskInstance](#taskinstance)
    1. [TaskSummaryAnalysis](#tasksummaryanalysis)
    1. [TaskTargetSet](#tasktargetset)
1. [Transformables](#transformables)
    1. [AnalysisLegend](#analysislegend)
    1. [DayPattern](#pattern)

# Model objects

## Analysis
| BR code | Entity | Rule |
|-|-|-|
| ANL-1 | Analysis | An Analysis' analysisType can only be one of the following values: <ul> <li/> Box <li/> Line </ul> |
| ANL-2 | Analysis | An Analysis' startDate and endDate must <ul> <li/> both be non-nil, OR <li/> both be nil </ul> |
| ANL-3 | Analysis | If an Analysis' startDate and endDate are both non-nil, its dateRange must be 0. |
| ANL-4 | Analysis | If an Analysis' startDate and endDate are both nil, its dateRange must be greater than 0. |
| ANL-5 | Analysis | An Analysis' order must be either <ul> <li/> -1 OR <li/> A unique number greater than or equal to 0 </ul>|
| ANL-6 | Analysis | An Analysis' name must be unique. |

## Task
| BR code | Entity | Rule |
|-|-|-|
| TASK-1 | Task | A Task's taskType can only be one of the following values: <ul> <li/> Recurring <li/> Specific </ul> |
| TASK-2 | Task | If a Task's taskType is recurring, startDate and endDate must be non-nil. |
| TASK-3 | Task | If a Task's taskType is recurring, targetSets must contain at least one TaskTargetSet. |
| TASK-4 | Task | If a Task's taskType is specific, instances must contain at least one TaskInstance. |
| TASK-5 | Task | A Task's name must be unique. |
| TASK-6 | Task | If a Task's taskType is recurring, endDate must be later than or equal to startDate. |
| TASK-7 | Task | A Task must be associated with one and only one TaskSummaryAnalysis. |

## Tag
| BR code | Entity | Rule |
|-|-|-|
| TAG-1 | Tag | A Tag's name must be unique. |
| TAG-2 | Tag | A Tag must be associated with at least one Task. |

## TaskInstance
| BR code | Entity | Rule |
|-|-|-|
| TI-1 | TaskInstance | A TaskInstance must be associated with one and only one Task. |
| TI-2 | TaskInstance | If a TaskInstance's associated Task's taskType is `Recurring`, the TaskInstance is associated with one and only one TaskTargetSet. |
| TI-3 | TaskInstance | If a TaskInstance's associated Task's taskType is `Specific`, the TaskInstance is not associated with a TaskTargetSet. |
| TI-4 | TaskInstance | TaskInstances with the same associated Task must each have a unique date. |

## TaskSummaryAnalysis
| BR code | Entity | Rule |
|-|-|-|
| TSA-1 | TaskSummaryAnalysis | A TaskSummaryAnalysis' analysisType can only be one of the following values: <ul> <li/> Box <li/> Line </ul> |
| TSA-2 | TaskSummaryAnalysis | A TaskSummaryAnalysis' startDate and endDate must <ul> <li/> both be non-nil, OR <li/> both be nil </ul> |
| TSA-3 | TaskSummaryAnalysis | If a TaskSummaryAnalysis' startDate and endDate are both non-nil, its dateRange must be 0. |
| TSA-4 | TaskSummaryAnalysis | If a TaskSummaryAnalysis' startDate and endDate are both nil, its dateRange must be greater than 0. |
| TSA-5 | TaskSummaryAnalysis | A TaskSummaryAnalysis must be associated with one and only one Task. |

## TaskTargetSet
| BR code | Entity | Rule |
|-|-|-|
| TTS-1 | TaskTargetSet | A TaskTargetSet's minOperator can only be one of the following values: <ul> <li/> Less than <li/> Less than or equal to <li/> Equal to <li/> N/A </ul> |
| TTS-2 | TaskTargetSet | A TaskTargetSet's maxOperator can only be one of the following values: <ul> <li/> Less than <li/> Less than or equal to <li/> N/A </ul> |
| TTS-3 | TaskTargetSet | If maxOperator is `N/A`, max is 0. |
| TTS-4 | TaskTargetSet | If minOperator is `N/A`, min is 0. |
| TTS-5 | TaskTargetSet | A TaskTargetSet's minOperator and maxOperator cannot both be `N/A`. |
| TTS-6 | TaskTargetSet | If a TaskTargetSet's minOperator is `Equal to`, its maxOperator must be `N/A`. |
| TTS-7 | TaskTargetSet | If a TaskTargetSet's minOperator and maxOperator are both not `N/A`, min must be less than max. |
| TTS-8 | TaskTargetSet | A TaskTargetSet must be associated with one and only one Task. |
| TTS-9 | TaskTargetSet | TaskTargetSets with the same associated Task must have each have a unique priority. |

# Transformables

## AnalysisLegend

## DayPattern