local M = {}

local function validate_options(options)
    -- User error
    if options.save == false and options.clipboard == false then
        error("Neither save nor copy to clipboard is enabled")
        return false
    end
    if options.save == true and options.clipboard == true then
        error("Both save and copy to clipboard can not be enabled")
        return false
    end
    -- My error (never happens)
    if options.type == "selection" then
        if options.start_line == -1 or options.end_line == -1 then
            print("Screenshot-nvim: Invalid start or end line")
            return false
        end
    end
    if options.save then
        if options.save_dir == "" then
            print("Screenshot-nvim: Invalid save directory")
            return false
        end
    end
    return true
end

function M.run(options)
    if not validate_options(options) then
        return
    end

    local command = {
        "carbon-now",
        "-h",
        options.path,
    }

    local success_message = ""
    if options.clipboard then
        table.insert(command, "-c")
        success_message = "Copied to clipboard"
    end

    if options.save then
        table.insert(command, "-l")
        table.insert(command, options.save_dir)
        table.insert(command, "-t")
        table.insert(command, options.file_name)
        success_message = "Saved to: " .. options.save_dir .. "/" .. options.file_name .. ".png"
    end

    if options.type == "selection" then
        table.insert(command, "-s")
        table.insert(command, options.start_line)
        table.insert(command, "-e")
        table.insert(command, options.end_line)
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
                print(success_message)
            else
                -- print("Job failed with exit code: " .. exit_code)
                print("Failed to capture - try again")
            end
        end,
        detach = true,
        stdout_buffered = true,
        stderr_buffered = true,
    }
    print(table.concat(command, " "))

    -- job_id = vim.fn.jobstart(command, callbacks)
    job_id = vim.fn.jobstart(table.concat(command, " "), callbacks)

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

return M
