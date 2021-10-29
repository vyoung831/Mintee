# Business Rules
This document specifies business rules that govern how Mintee stores data in persistent store. These business rules serve to both highlight business restrictions and centralize practices about how stored data represents different user scenarios.  
All business rules are [verified](../pull_request_template.md#business-rule-validation) after every test.
__Note:__ In this document, fields are __bolded__ and values are `backticked`.

1. [Model objects](#model-objects)
    - [Analysis](#analysis)
    - [Tag](#tag)
    - [Task](#task)
    - [TaskInstance](#taskinstance)
    - [TaskSummaryAnalysis](#tasksummaryanalysis)
    - [TaskTargetSet](#tasktargetset)
1. [Transformables](#transformables)
    - [AnalysisLegend](#analysislegend)
        - [CategorizedLegendEntry](#categorizedlegendentry)
        - [CompletionLegendEntry](#completionlegendentry)
    - [DayPattern](#daypattern)

# Model objects

## Analysis
| BR code | Entity | Rule |
|-|-|-|
| ANL-1 | Analysis | An Analysis' __analysisType__ can only be one of the following values: <ul> <li/> `Box` <li/> `Line` </ul> |
| ANL-2 | Analysis | An Analysis' __startDate__ and __endDate__ are either: <ul> <li/> both non-nil OR <li/> both nil </ul> |
| ANL-3 | Analysis | If an Analysis' __startDate__ and __endDate__ are both non-nil, then its __dateRange__ is `0`. |
| ANL-4 | Analysis | If an Analysis' __startDate__ and __endDate__ are both nil, then its __dateRange__ is greater than `0`. |
| ANL-5 | Analysis | An Analysis' __order__ is either: <ul> <li/> `-1` OR <li/> A unique number greater than or equal to `0` </ul>|
| ANL-6 | Analysis | An Analysis' __name__ is unique. |
| ANL-7 | Analysis | An Analysis' __legend__ is non-nil. |
| ANL-8 | Analysis | If an Analysis' __startDate__ and __endDate__ are both non-nil, then its __endDate__ is later than or equal to __startDate__. |

## Tag
| BR code | Entity | Rule |
|-|-|-|
| TAG-1 | Tag | A Tag's __name__ is unique. |
| TAG-2 | Tag | A Tag is associated with at least one Task. |

## Task
| BR code | Entity | Rule |
|-|-|-|
| TASK-1 | Task | A Task's __taskType__ can only be one of the following values: <ul> <li/> `Recurring` <li/> `Specific` </ul> |
| TASK-3 | Task | If a Task's __taskType__ is `Recurring`, then its __targetSets__ contains at least one TaskTargetSet. |
| TASK-4 | Task | If a Task's __taskType__ is `Specific`, then its __instances__ contains at least one TaskInstance. |
| TASK-5 | Task | A Task's __name__ is unique. |
| TASK-6 | Task | If a Task's __taskType__ is `Recurring`, then its __endDate__ is later than or equal to __startDate__. |
| TASK-7 | Task | A Task is associated with one and only one TaskSummaryAnalysis. |
| TASK-8 | Task | If a Task's __taskType__ is `Specific`, then its __startDate__ and __endDate__ are nil. |
| TASK-9 | Task | If a Task's __taskType__ is `Specific`, then its __targetSets__ is empty. |

## TaskInstance
| BR code | Entity | Rule |
|-|-|-|
| TI-1 | TaskInstance | A TaskInstance is associated with one and only one Task. |
| TI-2 | TaskInstance | If a TaskInstance's associated Task's __taskType__ is `Recurring`, then the TaskInstance is associated with a TaskTargetSet. |
| TI-3 | TaskInstance | If a TaskInstance's associated Task's __taskType__ is `Specific`, then the TaskInstance is not associated with a TaskTargetSet. |
| TI-4 | TaskInstance | TaskInstances with the same associated Task each have a unique __date__. |
| TI-5 | TaskInstance | A TaskInstance's __date__ is non-nil. |

## TaskSummaryAnalysis
| BR code | Entity | Rule |
|-|-|-|
| TSA-1 | TaskSummaryAnalysis | A TaskSummaryAnalysis' __analysisType__ can only be one of the following values: <ul> <li/> `Box` <li/> `Line` </ul> |
| TSA-2 | TaskSummaryAnalysis | A TaskSummaryAnalysis' __startDate__ and __endDate__ are either: <ul> <li/> both non-nil OR <li/> both nil </ul> |
| TSA-3 | TaskSummaryAnalysis | If a TaskSummaryAnalysis' __startDate__ and __endDate__ are both non-nil, then its __dateRange__ is `0`. |
| TSA-4 | TaskSummaryAnalysis | If a TaskSummaryAnalysis' __startDate__ and __endDate__ are both nil, then its __dateRange__ is greater than `0`. |
| TSA-5 | TaskSummaryAnalysis | A TaskSummaryAnalysis is associated with one and only one Task. |
| TSA-7 | TaskSummaryAnalysis | A TaskSummaryAnalysis' __legend__ is non-nil. |
| TSA-8 | TaskSummaryAnalysis | If a TaskSummaryAnalysis' __startDate__ and __endDate__ are both non-nil, then its __endDate__ is later than or equal to __startDate__. |

## TaskTargetSet
| BR code | Entity | Rule |
|-|-|-|
| TTS-1 | TaskTargetSet | A TaskTargetSet's __minOperator__ can only be one of the following values: <ul> <li/> `Less than` <li/> `Less than or equal to` <li/> `Equal to` <li/> `N/A` </ul> |
| TTS-2 | TaskTargetSet | A TaskTargetSet's __maxOperator__ can only be one of the following values: <ul> <li/> `Less than` <li/> `Less than or equal to` <li/> `N/A` </ul> |
| TTS-3 | TaskTargetSet | If a TaskTargetSet's __maxOperator__ is `N/A`, then its __max__ is `0`. |
| TTS-4 | TaskTargetSet | If a TaskTargetSet's __minOperator__ is `N/A`, then its __min__ is `0`. |
| TTS-5 | TaskTargetSet | A TaskTargetSet's __minOperator__ and __maxOperator__ cannot both be `N/A`. |
| TTS-6 | TaskTargetSet | If a TaskTargetSet's __minOperator__ is `Equal to`, then its __maxOperator__ is `N/A`. |
| TTS-7 | TaskTargetSet | If a TaskTargetSet's __minOperator__ and __maxOperator__ are both not `N/A`, then its __min__ is less than its __max__. |
| TTS-8 | TaskTargetSet | A TaskTargetSet is associated with one and only one Task. |
| TTS-9 | TaskTargetSet | TaskTargetSets with the same associated Task each have a unique priority. |
| TTS-10| TaskTargetSet | A TaskTargetSet's __pattern__ is non-nil. |

# Transformables

## AnalysisLegend
| BR code | Transformable custom class | Rule |
|-|-|-|
| ALGND-1 | AnalysisLegend | If an AnalysisLegend's __categorizedEntries__ is non-empty, then its __completionEntries__ is empty. |
| ALGND-2 | AnalysisLegend | If an AnalysisLegend's __completionEntries__ is non-empty, then its __categorizedEntries__ is empty. |

### CategorizedLegendEntry
| BR code | Class | Rule |
|-|-|-|
| CATLE-1 | CategorizedLegendEntry | A CategorizedLegendEntry's __category__ can only be one of the following values: <ul> <li/> `Reached target` <li/> `Under target` <li/> `Over target` </ul> |

### CompletionLegendEntry
| BR code | Class | Rule |
|-|-|-|
| CMPLE-1 | CompletionLegendEntry | A CompletionLegendEntry's __minOperator__ can only be one of the following values: <ul> <li/> `Less than` <li/> `Less than or equal to` <li/> `Equal to` <li/> `N/A` </ul> |
| CMPLE-2 | CompletionLegendEntry | A CompletionLegendEntry's __maxOperator__ can only be one of the following values: <ul> <li/> `Less than` <li/> `Less than or equal to` <li/> `N/A` </ul> |
| CMPLE-3 | CompletionLegendEntry | If a CompletionLegendEntry's __maxOperator__ is `N/A`, then its __max__ is `0`. |
| CMPLE-4 | CompletionLegendEntry | If a CompletionLegendEntry's __minOperator__ is `N/A`, then its __min__ is `0`. |
| CMPLE-5 | CompletionLegendEntry | A CompletionLegendEntry's __minOperator__ and __maxOperator__ cannot both be `N/A`. |
| CMPLE-6 | CompletionLegendEntry | If a CompletionLegendEntry's __minOperator__ is `Equal to`, then its __maxOperator__ is `N/A`. |
| CMPLE-7 | CompletionLegendEntry | If a CompletionLegendEntry's __minOperator__ and __maxOperator__ are both not `N/A`, then its __min__ is less than its __max__. |

## DayPattern
| BR code | Transformable custom class | Rule |
|-|-|-|
| DP-1 | DayPattern | A DayPattern's __type__ can only be one of the following values: <ul> <li/> `Days of week` <li/> `Weekdays of month` <li/> `Days of month` </ul> |
| DP-2 | DayPattern | If a DayPattern's __type__ is `Days of week`, then the following are true: <ul> <li/> __daysOfWeek__ is non-empty <li/> __weekdaysOfMonth__ is empty <li/> __daysOfMonth__ is empty </ul> |
| DP-3 | DayPattern | If a DayPattern's __type__ is `Weekdays of month`, then the following are true: <ul> <li/> __daysOfWeek__ is non-empty <li/> __weekdaysOfMonth__ is non-empty <li/> __daysOfMonth__ is empty </ul> |
| DP-4 | DayPattern | If a DayPattern's __type__ is `Days of month`, then the following are true: <ul> <li/> __daysOfWeek__ is empty <li/> __weekdaysOfMonth__ is empty <li/> __daysOfMonth__ is non-empty </ul> |