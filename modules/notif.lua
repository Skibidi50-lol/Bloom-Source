local function Notify(title, text, time)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Title",
            Text = text,
            Duration = time or 4
        })
    end)
end
