#pragma once

#include "fold.h"
#include "learn_context.h"
#include <catboost/libs/model/tensor_struct.h>
#include <catboost/libs/model/model.h>

#include <util/generic/vector.h>

void SetPermutedIndices(const TSplit& split,
                        const TAllFeatures& features,
                        int curDepth,
                        const TFold& fold,
                        yvector<TIndexType>* indices,
                        TLearnContext* ctx);

int GetRedundantSplitIdx(int curDepth, const yvector<TIndexType>& indices);

void DeleteSplit(int curDepth, int redundantIdx, TTensorStructure3* tree, yvector<TIndexType>* indices);

yvector<TIndexType> BuildIndices(const TFold& fold,
                          const TTensorStructure3& tree,
                          const TTrainData& data,
                          NPar::TLocalExecutor* localExecutor);

int GetDocCount(const TAllFeatures& features);

yvector<TIndexType> BuildIndices(const TTensorStructure3& tree,
                          const TFullModel& model,
                          const TAllFeatures& features,
                          const TCommonContext& ctx);
