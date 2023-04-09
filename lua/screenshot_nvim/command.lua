local M = {}
    -- local options = {
    --     type = "all",
    --     path = path,
    --     start_line = -1,
    --     end_line = -1,
    --     clipboard = true,
    --     save = false,
    --     current_dir = current_dir,
    --     file_name = file_name,
    -- }

local function run(options)
    local command = "carbon-now -h " .. options.path
    if options.clipboard then
        command = command .. " -c"
    end

    if options.type == "selection" then
        command = command .. " -s " .. options.start_line .. " -e " .. options.end_line
    elseif options.type == "all" then
        command = command .. " -l " .. options.current_dir .. " -t " .. options.file_name
    end

    local job_id = 0
    local callbacks = {
        -- standard out callbac
        on_stdout = function(_, data)
            if (#data == 0) or (#data == 1 and data[1] == "") then
                print("Failed to capture")
            end
        end,
        -- standard error callback
        on_stderr = function(_, data)
            if (#data == 0) or (#data == 1 and data[1] == "") then
                P(data)
            end
        end,
        on_exit = function(_, exit_code, _)
            vim.fn.jobstop(job_id)
            if exit_code == 0 then
                print("Job finished successfully")
            else
                -- print("Job failed with exit code: " .. exit_code)
                print("Failed to capture - try again")
            end
        end,
        detach = true,
        stdout_buffered = true,
        stderr_buffered = true,
    }

    job_id = vim.fn.jobstart(command, callbacks)

    if job_id <= 0 then
        print("Failed to capture - try again")
    end
    -- if job_id == 0 then
    --     print("Received invalid arguments")
    -- elseif job_id == -1 then
    --     print("cmd is not an executable")
    -- end

    vim.fn.chansend(job_id, "\n")
end


M.run = run

return M
