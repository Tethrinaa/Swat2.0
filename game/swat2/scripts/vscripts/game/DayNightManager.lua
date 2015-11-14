-- This file is responsible for managing the day night cycle and providing the callbacks for day -> night and night -> day

-- Notes: Dota2 has 12 hours for Day and 12 hours for Night
--  Swat has 9 hours for (starting at 8:00) and 15 hours for Night (starting at 17:00)
--  There does not seem to be a way to change the number of hours in day/night period in dota2
--  so we will employ a trick: let's make time move *faster* during the day and *slower* at night
--
--  Values:
--  0.002080000 = Normal rate of time in dota 2. 20 seconds == 1 hour
--  0.000693333 = Rate of time SWAT would want. 60 seconds == 1 hour
--  0.000924444 = Rate of time for SWAT during day. 45 seconds == 1 hour. (So day, which has 12 hours, takes 45 seconds * 12 == 9 minutes)
--  0.000554666 = Rate of time for SWAT during night. 75 seconds == 1 hour. (So night, which has 12 hours, takes 75 seconds * 12 == 15 minutes)
--
--  0.4722222 = initial time to start game at. (Original SWAT does not start at middle of the day period. It starts at 12:00 in an 8:00-17:00 period (so 4 hours
--  into a 9 hour period) We need to make dota 2 start a bit before noon so that it reach night at the 5 minute mark


-- The rate the clock should move during day and night respectively
DayNightManager = {}

DayNightManager.INITIAL_TIME = 0.4722222
DayNightManager.DAY_TIME_SPEED = 0.0009244444444
DayNightManager.NIGHT_TIME_SPEED = 0.0005546666666

DayNightManager.CVAR_NAME = "dota_time_of_day_rate"

SHOW_DAY_NIGHT_LOGS = SHOW_GAME_SYSTEM_LOGS

function DayNightManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self


    self.currentHour = 12 -- This is the "hour" of the day in SWAT time
    self.currentDay = 1
    self.isNight = false


    -- Set time to Noon (game will start PRE_GAME_TIME seconds before noon)
    -- Not sure why this needs to be in a Timer but it not putting it in a timer means the game will ignore it
    Timers:CreateTimer(1, function()
        GameRules:SetTimeOfDay(DayNightManager.INITIAL_TIME)

        self:setTimeOfDayRate(DayNightManager.DAY_TIME_SPEED)
    end)

    return o
end

-- Called when the horn blows and the game begins
-- Note: This is roughly 12:00
function DayNightManager:onGameStarted()
    self:startDayNightCycle()
end

function DayNightManager:startDayNightCycle()
    -- Starts at 12:00 (SWAT Time). So the first wait is shorter (5 minutes in swat time to reach 17:00)
    -- Because days are shorter, 12:00 SWAT Time is around 11:20
    -- It should take (18:00 - 11:20 = 6 hours 40 mintues) * (45 seconds per hour) == 5 minutes
    Timers:CreateTimer(60, function()
        self.currentHour = self.currentHour + 1
        if self.currentHour > 23 then
            self.currentHour = 0
        end
        self:onHour(self.currentHour)
        return 60
    end)
end

function DayNightManager:setTimeOfDayRate(rate)
    local current = Convars:GetInt(DayNightManager.CVAR_NAME) or 0
    if SHOW_DAY_NIGHT_LOGS then
        print("DayNight | updating cvarname=" .. DayNightManager.CVAR_NAME .. "  |  " .. current .. " -> " .. rate)
    end
    cvar_setf(DayNightManager.CVAR_NAME, rate)
end

-- Called every "hour" in game
function DayNightManager:onHour(hour)
    if hour == 0 then
        -- Midnight
        self.currentDay = self.currentDay + 1
        if SHOW_DAY_NIGHT_LOGS then
            print("DayNight | Midnight | New Day = " .. self.currentDay)
        end
        -- TODO Alert players that a new day has begun

        self:onMidnight()
    elseif hour == 8 then
        -- Dawn
        if SHOW_DAY_NIGHT_LOGS then
            print("DayNight | Dawn | Switching from Night to Day!")
        end
        self:setTimeOfDayRate(DayNightManager.DAY_TIME_SPEED)
        self.isNight = false

        self:onDayBegins()
    elseif hour == 12 then
        -- Noon
        if SHOW_DAY_NIGHT_LOGS then
            print("DayNight | Noon")
        end
        self:onNoon()
    elseif hour == 17 then
        -- Dusk
        if SHOW_DAY_NIGHT_LOGS then
            print("DayNight | Dusk | Switching from Day to Night!")
        end
        self:setTimeOfDayRate(DayNightManager.NIGHT_TIME_SPEED)
        self.isNight = true

        self:onNightBegins()
    end
end

-- Called when the time is 00:00 SWAT time. "Midnight" (note: this is not 00:00 in dota)
function DayNightManager:onMidnight()
    if self.currentDay == 2 then
        g_EnemyUpgrades:onFirstMidnight()
    end

    if g_GameManager.nightmareOrSurvivalValue > 0 then
        g_EnemyUpgrades:onTimeDifficultyIncreased()
    end
end

-- Called when day starts (except for the initial day everyone starts the game in)
function DayNightManager:onDayBegins()
    g_EnemyUpgrades:onTimeDifficultyIncreased()

    -- TODO: Hazard Pay
end

-- Called when the time is 12:00 SWAT time. "Noon" (note: this is not 12:00 in dota)
function DayNightManager:onNoon()
    if g_GameManager.nightmareOrSurvivalValue > 0 then
        g_EnemyUpgrades:onTimeDifficultyIncreased()
    end
end

-- Called when night begins (starting with the first night players experience)
function DayNightManager:onNightBegins()
    g_EnemyUpgrades:onTimeDifficultyIncreased()

    -- TODO: Hazard Pay
end
