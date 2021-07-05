# Business Rules
This document specifies business rules that govern how Mintee stores data in persistent store.  
Business rules listed here serve to not only highlight business restrictions, but also centralize rules about how stored data represents different user scenarios.  
All business rules are verified after each test that touches the persistent store. For more info, read [Mintee's test approach](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md#data-validators).  
__Note:__ In this document, fields are `backticked` and values are __bolded__.

1. [Model objects](#model-objects)
    1. [Analysis](#analysis)
    1. [Task](#task)
    1. [Tag](#tag)
    1. [TaskInstance](#taskinstance)
    1. [TaskSummaryAnalysis](#tasksummaryanalysis)
    1. [TaskTargetSet](#tasktargetset)
1. [Transformables](#transformables)
    1. [AnalysisLegend](#analysislegend)
        1. [CategorizedLegendEntry](#categorizedlegendentry)
        1. [CompletionLegendEntry](#completionlegendentry)
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
| TI-2 | TaskInstance | If a TaskInstance's associated Task's taskType is `Recurring`, the TaskInstance is associated with a TaskTargetSet. |
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
| BR code | Transformable custom class | Rule |
|-|-|-|
| ALGND-1 | ALGND-1 | If an AnalysisLegend's categorizedEntries is non-empty, then its completionEntries is empty. |
| ALGND-1 | ALGND-2 | If an AnalysisLegend's completionEntries is non-empty, then its categorizedEntries is empty. |

### CategorizedLegendEntry
| BR code | Class | Rule |
|-|-|-|
| CATLE-1 | CategorizedLegendEntry | A CategorizedLegendEntry's category can only be one of the following values: <ul> <li/> Reached target <li/> Under target <li/> Over target </ul> |

### CompletionLegendEntry
| BR code | Class | Rule |
|-|-|-|
| CMPLE-1 | CompletionLegendEntry | A CompletionLegendEntry's minOperator can only be one of the following values: <ul> <li/> Less than <li/> Less than or equal to <li/> Equal to <li/> N/A </ul> |
| CMPLE-2 | CompletionLegendEntry | A CompletionLegendEntry's maxOperator can only be one of the following values: <ul> <li/> Less than <li/> Less than or equal to <li/> N/A </ul> |
| CMPLE-3 | CompletionLegendEntry | If a CompletionLegendEntry's maxOperator is `N/A`, then its max is 0. |
| CMPLE-4 | CompletionLegendEntry | If a CompletionLegendEntry's minOperator is `N/A`, then its min is 0. |
| CMPLE-5 | CompletionLegendEntry | A CompletionLegendEntry's minOperator and maxOperator cannot both be `N/A`. |
| CMPLE-6 | CompletionLegendEntry | If a CompletionLegendEntry's minOperator is `Equal to`, then its maxOperator must be `N/A`. |
| CMPLE-7 | CompletionLegendEntry | If a CompletionLegendEntry's minOperator and maxOperator are both not `N/A`, then min must be less than max. |

## DayPattern
| BR code | Transformable custom class | Rule |
|-|-|-|
| DP-1 | DayPattern | A DayPattern's type can only be one of the following values: <ul> <li/> Days of week <li/> Weekdays of month <li/> Days of month </ul> |
| DP-2 | DayPattern | If a DayPattern's type is `Days of week`, then the following are true: <ul> <li/> daysOfWeek is non-empty <li/> weekdaysOfMonth is empty <li/> daysOfMonth is empty </ul> |
| DP-3 | DayPattern | If a DayPattern's type is `Weekdays of month`, then the following are true: <ul> <li/> daysOfWeek is empty <li/> weekdaysOfMonth is non-empty <li/> daysOfMonth is empty </ul> |
| DP-4 | DayPattern | If a DayPattern's type is `Days of month`, then the following are true: <ul> <li/> daysOfWeek is empty <li/> weekdaysOfMonth is empty <li/> daysOfMonth is non-empty </ul> |