--
-- Created by IntelliJ IDEA.
-- User: petrfiala
-- Date: 15/01/16
-- Time: 10:15
-- To change this template use File | Settings | File Templates.
--

----------------------------------------------------------------------
print '==> defining test procedure'

-- test function
function test()
    -- local vars
    local time = sys.clock()

    -- averaged param use?
    if average then
        cachedparams = parameters:clone()
        parameters:copy(average)
    end

    -- set model to evaluate mode (for modules that differ in training and testing, like Dropout)
    --    model:evaluate()

    -- test over test data
    print('==> testing on test set:')
    for t = 1, tesize do
        -- disp progress
        xlua.progress(t, tesize)

        -- get new sample
        local input = testData.data[t]
        local target = testData.labels[t]

        -- test sample
        local pred = model:forward(input)
        -- update confusion
        if (opt.model == 'va') then
            confusion:add(pred[1][1], target)
        else
            for d = 1, opt.digits do
                confusion:add(pred[d], target[i][d])
            end
        end
    end

    if (opt.model == 'va') then
        local out = model:forward(testData.data[tesize])
        ra = model:findModules('nn.RecurrentAttention')[1]
        print(testData.labels[tesize])
        print(out[1][1])

        local locations = ra.actions
        for _, l in pairs(locations) do
            print(l[1][1] .. " X " .. l[1][2])
        end
    end


    -- timing
    time = sys.clock() - time
    time = time / tesize
    print("\n==> time to test 1 sample = " .. (time * 1000) .. 'ms')

    -- print confusion matrix
    print(confusion)

    -- update log/plot
    testLogger:add { ['% mean class accuracy (test set)'] = confusion.totalValid * 100 }
    if opt.plot then
        testLogger:style { ['% mean class accuracy (test set)'] = '-' }
        testLogger:plot()
    end

    -- averaged param use?
    if average then
        -- restore parameters
        parameters:copy(cachedparams)
    end

    -- next iteration:
    confusion:zero()
end
