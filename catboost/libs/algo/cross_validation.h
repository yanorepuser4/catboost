#pragma once

#include "params.h"

#include <catboost/libs/data/pool.h>
#include <catboost/libs/logging/logging.h>

#include <util/generic/maybe.h>

#include <library/json/json_reader.h>

struct TCVIterationResults {
    double AverageTrain;
    double StdDevTrain;
    double AverageTest;
    double StdDevTest;
};

struct TCVResult {
    TString Metric;
    yvector<double> AverageTrain;
    yvector<double> StdDevTrain;
    yvector<double> AverageTest;
    yvector<double> StdDevTest;

    void AppendOneIterationResults(const TCVIterationResults& results) {
        AverageTrain.push_back(results.AverageTrain);
        StdDevTrain.push_back(results.StdDevTrain);
        AverageTest.push_back(results.AverageTest);
        StdDevTest.push_back(results.StdDevTest);
    }
};

void CrossValidate(
    const NJson::TJsonValue& jsonParams,
    const TMaybe<TCustomObjectiveDescriptor>& objectiveDescriptor,
    const TMaybe<TCustomMetricDescriptor>& evalMetricDescriptor,
    TPool& pool,
    const TCrossValidationParams& cvParams,
    yvector<TCVResult>* results);
