--[[
    Death Analysis Engine
    Analyzes death snapshots and calculates what could have saved the player
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Analysis Constants
--------------------------------------------------------------------------------

local VERDICT_TYPES = {
    PREVENTABLE = { text = "PREVENTABLE", color = "|cFFFF0000" },
    LIKELY_PREVENTABLE = { text = "LIKELY PREVENTABLE", color = "|cFFFF8800" },
    DIFFICULT = { text = "DIFFICULT TO PREVENT", color = "|cFFFFFF00" },
    UNAVOIDABLE = { text = "UNAVOIDABLE", color = "|cFF00FF00" },
}

-- Avoidable damage database is now loaded from AvoidableDamageDatabase.lua
-- The database is built during initialization via DA:BuildAvoidableDamageDB()
-- DA.AvoidableDamageDB will be populated with all dungeon mechanics

--------------------------------------------------------------------------------
-- Main Analysis Function
--------------------------------------------------------------------------------

function DA:AnalyzeDeath(snapshot)
    if not snapshot or not snapshot.events then
        self:Debug("Invalid snapshot for analysis")
        return
    end
    
    local analysis = {
        timeline = {},
        totalDamageTaken = 0,
        totalHealingReceived = 0,
        avoidableDamage = 0,
        avoidableEvents = {},
        unusedDefensives = {},
        healingGaps = {},
        killingBlow = nil,
        verdict = nil,
        score = 0,
        suggestions = {},
    }
    
    -- Process events into timeline
    analysis.timeline = self:BuildTimeline(snapshot)
    
    -- Calculate damage and healing totals
    self:CalculateTotals(snapshot, analysis)
    
    -- Identify avoidable damage
    self:IdentifyAvoidableDamage(snapshot, analysis)
    
    -- Analyze unused defensives
    self:AnalyzeUnusedDefensives(snapshot, analysis)
    
    -- Find healing gaps
    self:FindHealingGaps(snapshot, analysis)
    
    -- Calculate "would have survived" scenarios
    self:CalculateSurvivalScenarios(snapshot, analysis)
    
    -- Generate verdict and score
    self:GenerateVerdict(snapshot, analysis)
    
    -- Store analysis in snapshot
    snapshot.analysis = analysis
    snapshot.verdict = analysis.verdict.text
    snapshot.score = analysis.score
    snapshot.killingBlow = analysis.killingBlow
    
    return analysis
end

--------------------------------------------------------------------------------
-- Timeline Building
--------------------------------------------------------------------------------

function DA:BuildTimeline(snapshot)
    local timeline = {}
    local deathTime = snapshot.timestamp
    
    for _, event in ipairs(snapshot.events) do
        local isAvoidable = self:IsDamageAvoidable(event.spellID)
        local avoidanceInfo = nil
        if isAvoidable then
            avoidanceInfo = self:GetAvoidanceInfo(event.spellID)
        end
        
        local entry = {
            relativeTime = event.timestamp - deathTime,
            type = event.type,
            source = event.source,
            spellID = event.spellID,
            spellName = event.spellName,
            amount = event.amount or 0,
            healthPercent = event.healthPercent or 0,
            isAvoidable = isAvoidable,
            avoidanceInfo = avoidanceInfo,
            isCritical = event.critical,
            overkill = event.overkill or 0,
        }
        
        table.insert(timeline, entry)
    end
    
    -- Sort by time
    table.sort(timeline, function(a, b)
        return a.relativeTime < b.relativeTime
    end)
    
    return timeline
end

--------------------------------------------------------------------------------
-- Damage/Healing Calculation
--------------------------------------------------------------------------------

function DA:CalculateTotals(snapshot, analysis)
    local lastDamageEvent = nil
    
    for _, event in ipairs(snapshot.events) do
        if event.type == "DAMAGE" then
            analysis.totalDamageTaken = analysis.totalDamageTaken + (event.amount or 0)
            lastDamageEvent = event
        elseif event.type == "HEALING" then
            analysis.totalHealingReceived = analysis.totalHealingReceived + (event.amount or 0)
        end
    end
    
    -- Identify killing blow
    if lastDamageEvent then
        analysis.killingBlow = {
            source = lastDamageEvent.source,
            spellName = lastDamageEvent.spellName,
            spellID = lastDamageEvent.spellID,
            amount = lastDamageEvent.amount,
            overkill = lastDamageEvent.overkill or 0,
        }
    end
end

--------------------------------------------------------------------------------
-- Avoidable Damage Detection
--------------------------------------------------------------------------------

function DA:IsDamageAvoidable(spellID, spellName)
    -- Check if we have the database built
    if not self.AvoidableDamageDB then
        return false
    end
    
    -- Check spell ID (but not for spell ID 0 which is melee)
    if spellID and spellID > 0 and self.AvoidableDamageDB[spellID] then
        return true
    end
    
    -- Check environmental types by name
    if self.EnvironmentalTypes and self.EnvironmentalTypes[spellName] then
        return true
    end
    
    return false
end

function DA:GetAvoidanceInfo(spellID, spellName)
    -- First check environmental types by name (e.g., "Falling", "Lava")
    if self.EnvironmentalTypes and self.EnvironmentalTypes[spellName] then
        local envInfo = self.EnvironmentalTypes[spellName]
        local category = self.AvoidanceCategories and self.AvoidanceCategories[envInfo.category]
        return {
            name = envInfo.name,
            avoidance = envInfo.avoidance,
            category = envInfo.category,
            categoryInfo = category,
            dungeon = "Environment",
        }
    end
    
    -- Check by spell ID (but not for spell ID 0 which is melee)
    if spellID and spellID > 0 then
        -- Use the new detailed info function if available
        if self.GetAvoidableInfo then
            return self:GetAvoidableInfo(spellID)
        end
        -- Fallback to basic lookup
        return self.AvoidableDamageDB and self.AvoidableDamageDB[spellID]
    end
    
    return nil
end

function DA:IdentifyAvoidableDamage(snapshot, analysis)
    for _, event in ipairs(snapshot.events) do
        if event.type == "DAMAGE" then
            -- Pass both spellID and spellName for proper lookup
            local avoidanceInfo = self:GetAvoidanceInfo(event.spellID, event.spellName)
            if avoidanceInfo then
                analysis.avoidableDamage = analysis.avoidableDamage + (event.amount or 0)
                table.insert(analysis.avoidableEvents, {
                    spellID = event.spellID,
                    spellName = event.spellName,
                    amount = event.amount,
                    avoidance = avoidanceInfo.avoidance,
                    category = avoidanceInfo.category,
                    categoryInfo = avoidanceInfo.categoryInfo,
                    dungeon = avoidanceInfo.dungeon,
                    timestamp = event.timestamp,
                })
            end
        end
    end
    
    -- Calculate avoidable percentage
    if analysis.totalDamageTaken > 0 then
        analysis.avoidablePercent = (analysis.avoidableDamage / analysis.totalDamageTaken) * 100
    else
        analysis.avoidablePercent = 0
    end
end

--------------------------------------------------------------------------------
-- Unused Defensive Analysis
--------------------------------------------------------------------------------

function DA:AnalyzeUnusedDefensives(snapshot, analysis)
    local readyDefensives = snapshot.readyDefensives or {}
    
    for _, def in ipairs(readyDefensives) do
        -- Calculate how much damage this defensive could have prevented
        local potentialReduction = 0
        local defInfo = def.info
        
        if defInfo.reduction and defInfo.reduction > 0 then
            -- Calculate based on damage reduction
            potentialReduction = analysis.totalDamageTaken * (defInfo.reduction / 100)
        end
        
        -- Special handling for specific defensive types
        if defInfo.type == "immunity" then
            -- Immunities would prevent all damage during their window
            potentialReduction = analysis.totalDamageTaken
        elseif defInfo.notes and defInfo.notes:find("heal") then
            -- Healing cooldowns
            local playerInfo = snapshot.playerInfo or self:GetPlayerInfo()
            local maxHealth = playerInfo.maxHealth or UnitHealthMax("player")
            if defInfo.notes:find("30%%") then
                potentialReduction = maxHealth * 0.30
            elseif defInfo.notes:find("25%%") then
                potentialReduction = maxHealth * 0.25
            elseif defInfo.notes:find("Full heal") or defInfo.notes:find("Lay on Hands") then
                potentialReduction = maxHealth
            end
        end
        
        local unusedDef = {
            spellID = def.spellID,
            name = defInfo.name,
            reduction = defInfo.reduction or 0,
            type = defInfo.type,
            notes = defInfo.notes,
            readyFor = def.readyFor,
            potentialReduction = potentialReduction,
        }
        
        table.insert(analysis.unusedDefensives, unusedDef)
    end
    
    -- Sort by potential impact
    table.sort(analysis.unusedDefensives, function(a, b)
        return a.potentialReduction > b.potentialReduction
    end)
end

--------------------------------------------------------------------------------
-- Healing Gap Analysis
--------------------------------------------------------------------------------

function DA:FindHealingGaps(snapshot, analysis)
    local events = snapshot.events
    local lastHealTime = nil
    local deathTime = snapshot.timestamp
    
    -- Find periods without healing
    for _, event in ipairs(events) do
        if event.type == "HEALING" then
            if lastHealTime then
                local gap = event.timestamp - lastHealTime
                if gap > 2.0 then -- 2 second threshold for "gap"
                    table.insert(analysis.healingGaps, {
                        startTime = lastHealTime - deathTime,
                        endTime = event.timestamp - deathTime,
                        duration = gap,
                    })
                end
            end
            lastHealTime = event.timestamp
        end
    end
    
    -- Check for gap between last heal and death
    if lastHealTime then
        local finalGap = deathTime - lastHealTime
        if finalGap > 2.0 then
            table.insert(analysis.healingGaps, {
                startTime = lastHealTime - deathTime,
                endTime = 0,
                duration = finalGap,
                isFinalGap = true,
            })
        end
    end
end

--------------------------------------------------------------------------------
-- "Would Have Survived" Calculator
--------------------------------------------------------------------------------

function DA:CalculateSurvivalScenarios(snapshot, analysis)
    analysis.survivalScenarios = {}
    
    local playerInfo = snapshot.playerInfo or self:GetPlayerInfo()
    local maxHealth = playerInfo.maxHealth or UnitHealthMax("player")
    local overkill = (analysis.killingBlow and analysis.killingBlow.overkill) or 0
    
    -- Scenario 1: Avoiding all avoidable damage
    if analysis.avoidableDamage > 0 then
        local wouldSurvive = analysis.avoidableDamage > overkill
        local remainingHealth = analysis.avoidableDamage - overkill
        local remainingPercent = (remainingHealth / maxHealth) * 100
        
        table.insert(analysis.survivalScenarios, {
            type = "AVOID_DAMAGE",
            description = "Avoiding all avoidable damage",
            wouldSurvive = wouldSurvive,
            remainingHealth = math.max(0, remainingHealth),
            remainingPercent = math.max(0, remainingPercent),
            damageAvoided = analysis.avoidableDamage,
        })
    end
    
    -- Scenario 2: Using each unused defensive
    for _, def in ipairs(analysis.unusedDefensives) do
        if def.potentialReduction > 0 then
            local wouldSurvive = def.potentialReduction > overkill
            local remainingHealth = def.potentialReduction - overkill
            local remainingPercent = (remainingHealth / maxHealth) * 100
            
            table.insert(analysis.survivalScenarios, {
                type = "USE_DEFENSIVE",
                description = "Using " .. def.name,
                defensive = def,
                wouldSurvive = wouldSurvive,
                remainingHealth = math.max(0, remainingHealth),
                remainingPercent = math.max(0, remainingPercent),
                damageReduced = def.potentialReduction,
            })
        end
    end
    
    -- Scenario 3: Combined (avoid damage + best defensive)
    if analysis.avoidableDamage > 0 and #analysis.unusedDefensives > 0 then
        local bestDef = analysis.unusedDefensives[1]
        local combinedReduction = analysis.avoidableDamage + (bestDef.potentialReduction or 0)
        local wouldSurvive = combinedReduction > overkill
        local remainingHealth = combinedReduction - overkill
        local remainingPercent = (remainingHealth / maxHealth) * 100
        
        table.insert(analysis.survivalScenarios, {
            type = "COMBINED",
            description = "Avoiding damage + using " .. bestDef.name,
            wouldSurvive = wouldSurvive,
            remainingHealth = math.max(0, remainingHealth),
            remainingPercent = math.max(0, remainingPercent),
            damageReduced = combinedReduction,
        })
    end
    
    -- Sort scenarios by remaining health
    table.sort(analysis.survivalScenarios, function(a, b)
        return a.remainingHealth > b.remainingHealth
    end)
end

--------------------------------------------------------------------------------
-- Advanced Scoring Calculations
--------------------------------------------------------------------------------

-- Calculate reaction time: time from first significant damage to death
function DA:CalculateReactionTime(snapshot, analysis)
    local deathTime = snapshot.timestamp
    local firstDamageTime = nil

    -- Find first damage event that took >5% of max health
    local playerInfo = snapshot.playerInfo or self:GetPlayerInfo()
    local maxHealth = playerInfo.maxHealth or UnitHealthMax("player")
    local significantThreshold = maxHealth * 0.05

    for _, event in ipairs(snapshot.events) do
        if event.type == "DAMAGE" and (event.amount or 0) >= significantThreshold then
            firstDamageTime = event.timestamp
            break
        end
    end

    -- Fallback: if no significant damage, use first damage event
    if not firstDamageTime then
        for _, event in ipairs(snapshot.events) do
            if event.type == "DAMAGE" then
                firstDamageTime = event.timestamp
                break
            end
        end
    end

    if firstDamageTime then
        return deathTime - firstDamageTime
    end

    return 0
end

-- Calculate reaction time modifier for scoring
function DA:CalculateReactionTimeModifier(reactionTime)
    if reactionTime < 1.0 then
        return 1.5  -- No time to react, bonus
    elseif reactionTime < 2.0 then
        return 1.0  -- Minimal reaction time
    elseif reactionTime < 4.0 then
        return 0.5  -- Limited reaction time
    elseif reactionTime < 8.0 then
        return 0.0  -- Reasonable reaction time
    else
        return -0.5 -- Plenty of time to react, penalty
    end
end

-- Calculate burst damage factor (one-shot vs gradual)
function DA:CalculateBurstFactor(snapshot, analysis)
    if analysis.totalDamageTaken <= 0 then
        return 0
    end

    -- Collect all damage amounts
    local damageEvents = {}
    for _, event in ipairs(snapshot.events) do
        if event.type == "DAMAGE" and (event.amount or 0) > 0 then
            table.insert(damageEvents, event.amount)
        end
    end

    if #damageEvents == 0 then
        return 0
    end

    -- Sort by damage (highest first)
    table.sort(damageEvents, function(a, b) return a > b end)

    local largestHit = damageEvents[1]
    local largestPercent = (largestHit / analysis.totalDamageTaken) * 100

    -- One-shot detection
    if largestPercent >= 90 then
        return 1.0  -- Practically one-shot
    elseif #damageEvents >= 2 then
        local topTwo = damageEvents[1] + damageEvents[2]
        local topTwoPercent = (topTwo / analysis.totalDamageTaken) * 100
        if topTwoPercent >= 80 then
            return 0.5  -- Burst damage (1-2 big hits)
        end
    end

    if largestPercent < 40 then
        return 0.0  -- Gradual damage, no bonus
    end

    return 0.0
end

-- Analyze health trajectory over the combat window
function DA:CalculateHealthTrajectory(snapshot, analysis)
    local trajectory = {
        type = "unknown",
        startingHealth = 100,
        timeAtLowHealth = 0,  -- Time spent below 30%
        modifier = 0,
    }

    local deathTime = snapshot.timestamp
    local lowHealthThreshold = 30
    local lastEventTime = nil
    local lastHealthPercent = 100

    -- Find starting health and track time at low HP
    for _, event in ipairs(snapshot.events) do
        if event.healthPercent and event.healthPercent > 0 then
            if not trajectory.startingHealth or event.timestamp == snapshot.events[1].timestamp then
                trajectory.startingHealth = event.healthPercent
            end

            -- Track time at low health
            if lastEventTime and lastHealthPercent < lowHealthThreshold then
                trajectory.timeAtLowHealth = trajectory.timeAtLowHealth + (event.timestamp - lastEventTime)
            end

            lastEventTime = event.timestamp
            lastHealthPercent = event.healthPercent
        end
    end

    -- Classify trajectory
    if trajectory.startingHealth >= 70 then
        trajectory.type = "sudden"
        trajectory.modifier = 0.5  -- Bonus for sudden death from high HP
    elseif trajectory.timeAtLowHealth > 5.0 then
        trajectory.type = "lingering"
        trajectory.modifier = -0.5  -- Penalty for lingering at low HP
    else
        trajectory.type = "gradual"
        trajectory.modifier = 0.0  -- Neutral
    end

    return trajectory
end

-- Calculate category-weighted avoidable damage percentage
function DA:CalculateWeightedAvoidablePercent(analysis)
    if analysis.totalDamageTaken <= 0 then
        return 0
    end

    local weightedAvoidable = 0

    for _, evt in ipairs(analysis.avoidableEvents or {}) do
        local weight = self:GetCategoryWeight(evt.category)
        weightedAvoidable = weightedAvoidable + ((evt.amount or 0) * weight)
    end

    return (weightedAvoidable / analysis.totalDamageTaken) * 100
end

-- Calculate graduated penalty for avoidable damage
function DA:CalculateAvoidablePenalty(avoidablePercent)
    if avoidablePercent <= 0 then
        return 0
    elseif avoidablePercent <= 10 then
        return 0.5  -- Minimal
    elseif avoidablePercent <= 25 then
        return 1.5  -- Some
    elseif avoidablePercent <= 40 then
        return 2.5  -- Moderate
    elseif avoidablePercent <= 60 then
        return 3.5  -- Significant
    else
        return 4.5  -- Mostly avoidable
    end
end

-- Calculate pre-death health modifier
function DA:CalculatePreDeathHealthModifier(snapshot, analysis)
    -- Find health at the start of the fatal damage sequence
    local fatalSequenceStart = nil
    local healthAtStart = nil
    local overkill = (analysis.killingBlow and analysis.killingBlow.overkill) or 0

    -- Look backwards for when health was still "safe"
    local playerInfo = snapshot.playerInfo or self:GetPlayerInfo()
    local maxHealth = playerInfo.maxHealth or UnitHealthMax("player")

    for _, event in ipairs(snapshot.events) do
        if event.healthPercent and event.healthPercent > 0 then
            if not healthAtStart then
                healthAtStart = event.healthPercent
            end
        end
    end

    -- Return modifier based on starting health
    if healthAtStart and healthAtStart >= 80 then
        return 0.5  -- Was at high HP, death was sudden
    elseif healthAtStart and healthAtStart <= 30 then
        return -0.5  -- Was already low, should have been more careful
    end

    return 0.0
end

-- Calculate weighted defensive penalty based on availability window
function DA:CalculateWeightedDefensivePenalty(analysis)
    local penalty = 0

    for _, def in ipairs(analysis.unusedDefensives or {}) do
        -- Only count impactful defensives (>=20% reduction or immunity)
        if def.reduction >= 20 or def.type == "immunity" then
            local basePenalty = 1.0

            -- Weight by how long it was available
            local readyFor = def.readyFor or 30
            if readyFor > 30 then
                basePenalty = 1.0  -- Full penalty, had plenty of time
            elseif readyFor > 15 then
                basePenalty = 0.8  -- 80% penalty
            elseif readyFor > 5 then
                basePenalty = 0.5  -- 50% penalty
            else
                basePenalty = 0.2  -- 20% penalty, just came off CD
            end

            penalty = penalty + basePenalty
        end
    end

    -- Cap at 3 points max
    return math.min(3.0, penalty)
end

-- Calculate healing gap penalty
function DA:CalculateHealingGapPenalty(analysis)
    local penalty = 0

    for _, gap in ipairs(analysis.healingGaps or {}) do
        if gap.isFinalGap and gap.duration > 4.0 then
            penalty = penalty + 0.5
        end
    end

    return math.min(1.0, penalty)
end

--------------------------------------------------------------------------------
-- Verdict Generation
--------------------------------------------------------------------------------

function DA:GenerateVerdict(snapshot, analysis)
    local suggestions = {}

    -- Initialize score breakdown for transparency
    local scoreBreakdown = {
        base = 10.0,
        avoidablePenalty = 0,
        reactionBonus = 0,
        burstBonus = 0,
        trajectoryModifier = 0,
        defensivePenalty = 0,
        healingPenalty = 0,
        preDeathModifier = 0,
        final = 10.0,
    }

    -- Check survival scenarios
    local couldHaveSurvived = false
    local bestScenario = nil

    for _, scenario in ipairs(analysis.survivalScenarios or {}) do
        if scenario.wouldSurvive then
            couldHaveSurvived = true
            if not bestScenario or scenario.remainingHealth > bestScenario.remainingHealth then
                bestScenario = scenario
            end
        end
    end

    -- ========================================================================
    -- NEW SCORING SYSTEM
    -- ========================================================================

    local score = 10.0

    -- 1. Avoidable Damage (category-weighted, graduated)
    analysis.weightedAvoidablePercent = self:CalculateWeightedAvoidablePercent(analysis)
    local avoidablePenalty = self:CalculateAvoidablePenalty(analysis.weightedAvoidablePercent)
    score = score - avoidablePenalty
    scoreBreakdown.avoidablePenalty = avoidablePenalty

    if analysis.weightedAvoidablePercent > 40 then
        table.insert(suggestions, string.format("Significant avoidable damage (%.0f%% weighted)", analysis.weightedAvoidablePercent))
    elseif analysis.weightedAvoidablePercent > 20 then
        table.insert(suggestions, string.format("Some avoidable damage taken (%.0f%% weighted)", analysis.weightedAvoidablePercent))
    elseif analysis.weightedAvoidablePercent > 0 then
        table.insert(suggestions, string.format("Minor avoidable damage (%.0f%% weighted)", analysis.weightedAvoidablePercent))
    end

    -- 2. Reaction Time Factor
    analysis.reactionTime = self:CalculateReactionTime(snapshot, analysis)
    local reactionModifier = self:CalculateReactionTimeModifier(analysis.reactionTime)
    score = score + reactionModifier
    scoreBreakdown.reactionBonus = reactionModifier

    if analysis.reactionTime < 1.5 then
        table.insert(suggestions, string.format("Very fast death (%.1fs) - limited reaction time", analysis.reactionTime))
    elseif analysis.reactionTime > 10.0 then
        table.insert(suggestions, string.format("Slow death (%.1fs) - had time to react", analysis.reactionTime))
    end

    -- 3. Burst Damage Factor
    analysis.burstFactor = self:CalculateBurstFactor(snapshot, analysis)
    score = score + analysis.burstFactor
    scoreBreakdown.burstBonus = analysis.burstFactor

    if analysis.burstFactor >= 1.0 then
        table.insert(suggestions, "One-shot death - difficult to prevent")
    elseif analysis.burstFactor >= 0.5 then
        table.insert(suggestions, "Burst damage - 1-2 large hits caused death")
    end

    -- 4. Health Trajectory
    analysis.healthTrajectory = self:CalculateHealthTrajectory(snapshot, analysis)
    score = score + analysis.healthTrajectory.modifier
    scoreBreakdown.trajectoryModifier = analysis.healthTrajectory.modifier

    if analysis.healthTrajectory.type == "lingering" then
        table.insert(suggestions, "Spent time at low HP before dying - play more cautiously")
    end

    -- 5. Unused Defensives (weighted by availability)
    local defensivePenalty = self:CalculateWeightedDefensivePenalty(analysis)
    score = score - defensivePenalty
    scoreBreakdown.defensivePenalty = defensivePenalty

    -- Count impactful defensives for verdict
    local impactfulDefensives = 0
    for _, def in ipairs(analysis.unusedDefensives or {}) do
        if def.reduction >= 20 or def.type == "immunity" then
            impactfulDefensives = impactfulDefensives + 1
        end
    end

    if impactfulDefensives >= 2 then
        table.insert(suggestions, "Multiple defensive cooldowns were available")
    elseif impactfulDefensives == 1 then
        local def = nil
        for _, d in ipairs(analysis.unusedDefensives or {}) do
            if d.reduction >= 20 or d.type == "immunity" then
                def = d
                break
            end
        end
        if def then
            table.insert(suggestions, def.name .. " was available and could have helped")
        end
    end

    -- 6. Healing Gap Penalty
    local healingPenalty = self:CalculateHealingGapPenalty(analysis)
    score = score - healingPenalty
    scoreBreakdown.healingPenalty = healingPenalty

    if healingPenalty > 0 then
        table.insert(suggestions, "No healing received in final moments")
    end

    -- 7. Pre-Death Health State
    local preDeathModifier = self:CalculatePreDeathHealthModifier(snapshot, analysis)
    score = score + preDeathModifier
    scoreBreakdown.preDeathModifier = preDeathModifier

    -- ========================================================================
    -- FINALIZE SCORE
    -- ========================================================================

    -- Clamp score to 1-10 range
    score = math.max(1, math.min(10, score))

    -- Round to 1 decimal place for display
    score = math.floor(score * 10 + 0.5) / 10
    scoreBreakdown.final = score

    -- ========================================================================
    -- DETERMINE VERDICT (Updated thresholds)
    -- ========================================================================

    local verdict
    if couldHaveSurvived and (analysis.weightedAvoidablePercent > 35 or impactfulDefensives >= 2) then
        verdict = VERDICT_TYPES.PREVENTABLE
    elseif couldHaveSurvived and score <= 6 then
        verdict = VERDICT_TYPES.LIKELY_PREVENTABLE
    elseif couldHaveSurvived then
        verdict = VERDICT_TYPES.DIFFICULT
    elseif #(analysis.unusedDefensives or {}) > 0 or analysis.avoidableDamage > 0 then
        verdict = VERDICT_TYPES.DIFFICULT
    else
        verdict = VERDICT_TYPES.UNAVOIDABLE
    end

    -- Add best scenario to top of suggestions
    if bestScenario then
        table.insert(suggestions, 1, bestScenario.description .. " would have saved you with " ..
            string.format("%.0f%%", bestScenario.remainingPercent) .. " HP remaining")
    end

    -- Store results
    analysis.verdict = verdict
    analysis.score = score
    analysis.suggestions = suggestions
    analysis.bestScenario = bestScenario
    analysis.scoreBreakdown = scoreBreakdown
end

--------------------------------------------------------------------------------
-- Utility: Get Analysis Summary Text
--------------------------------------------------------------------------------

function DA:GetAnalysisSummary(snapshot)
    if not snapshot or not snapshot.analysis then
        return "No analysis available"
    end

    local a = snapshot.analysis
    local lines = {}

    -- Verdict line with score
    table.insert(lines, a.verdict.color .. a.verdict.text .. "|r - Score: " .. a.score .. "/10")

    -- Score breakdown (compact)
    if a.scoreBreakdown then
        local sb = a.scoreBreakdown
        local breakdownParts = {}

        if sb.avoidablePenalty > 0 then
            table.insert(breakdownParts, string.format("|cFFFF6666-%.1f avoid|r", sb.avoidablePenalty))
        end
        if sb.defensivePenalty > 0 then
            table.insert(breakdownParts, string.format("|cFFFFFF66-%.1f def|r", sb.defensivePenalty))
        end
        if sb.reactionBonus > 0 then
            table.insert(breakdownParts, string.format("|cFF66FF66+%.1f react|r", sb.reactionBonus))
        elseif sb.reactionBonus < 0 then
            table.insert(breakdownParts, string.format("|cFFFF6666%.1f react|r", sb.reactionBonus))
        end
        if sb.burstBonus > 0 then
            table.insert(breakdownParts, string.format("|cFF66FF66+%.1f burst|r", sb.burstBonus))
        end
        if sb.trajectoryModifier ~= 0 then
            local sign = sb.trajectoryModifier > 0 and "+" or ""
            local color = sb.trajectoryModifier > 0 and "|cFF66FF66" or "|cFFFF6666"
            table.insert(breakdownParts, string.format("%s%s%.1f traj|r", color, sign, sb.trajectoryModifier))
        end

        if #breakdownParts > 0 then
            table.insert(lines, "|cFF888888Score: " .. table.concat(breakdownParts, " ") .. "|r")
        end
    end

    -- Killing blow
    if a.killingBlow then
        local kbText = "Killed by: " .. a.killingBlow.spellName .. " (" .. self:FormatNumber(a.killingBlow.amount) .. ")"
        -- Check if killing blow was avoidable
        local kbInfo = self:GetAvoidanceInfo(a.killingBlow.spellID)
        if kbInfo and kbInfo.categoryInfo then
            kbText = kbText .. " " .. kbInfo.categoryInfo.color .. "[" .. kbInfo.categoryInfo.name:upper() .. "]|r"
        end
        table.insert(lines, kbText)
    end

    -- Key stats with reaction time
    local statsLine = string.format("Total damage: %s | Healing: %s",
        self:FormatNumber(a.totalDamageTaken),
        self:FormatNumber(a.totalHealingReceived)
    )
    if a.reactionTime then
        statsLine = statsLine .. string.format(" | Time: %.1fs", a.reactionTime)
    end
    table.insert(lines, statsLine)

    -- Avoidable damage with category breakdown
    if a.avoidableDamage > 0 then
        local avoidableText = string.format("|cFFFF8800Avoidable: %s (%.0f%% raw, %.0f%% weighted)|r",
            self:FormatNumber(a.avoidableDamage),
            a.avoidablePercent,
            a.weightedAvoidablePercent or a.avoidablePercent
        )

        -- Count categories for summary
        if a.avoidableEvents and #a.avoidableEvents > 0 then
            local categories = {}
            for _, evt in ipairs(a.avoidableEvents) do
                if evt.category then
                    categories[evt.category] = (categories[evt.category] or 0) + 1
                end
            end
            local catList = {}
            for cat, count in pairs(categories) do
                local catInfo = self.AvoidanceCategories and self.AvoidanceCategories[cat]
                if catInfo then
                    table.insert(catList, catInfo.color .. count .. " " .. catInfo.name:lower() .. "|r")
                end
            end
            if #catList > 0 then
                avoidableText = avoidableText .. " - " .. table.concat(catList, ", ")
            end
        end

        table.insert(lines, avoidableText)
    end

    -- Burst/trajectory indicators
    local indicators = {}
    if a.burstFactor and a.burstFactor >= 1.0 then
        table.insert(indicators, "|cFFFF00FFOne-Shot|r")
    elseif a.burstFactor and a.burstFactor >= 0.5 then
        table.insert(indicators, "|cFFFF8800Burst|r")
    end
    if a.healthTrajectory then
        if a.healthTrajectory.type == "sudden" then
            table.insert(indicators, "|cFF00FF00Sudden|r")
        elseif a.healthTrajectory.type == "lingering" then
            table.insert(indicators, "|cFFFFFF00Lingering|r")
        end
    end
    if #indicators > 0 then
        table.insert(lines, "Death type: " .. table.concat(indicators, " "))
    end

    -- Unused defensives
    if a.unusedDefensives and #a.unusedDefensives > 0 then
        local defNames = {}
        for i = 1, math.min(3, #a.unusedDefensives) do
            table.insert(defNames, a.unusedDefensives[i].name)
        end
        table.insert(lines, "|cFFFFFF00Unused: " .. table.concat(defNames, ", ") .. "|r")
    end

    -- Best suggestion
    if a.suggestions and #a.suggestions > 0 then
        table.insert(lines, "|cFF00FF00> " .. a.suggestions[1] .. "|r")
    end

    return table.concat(lines, "\n")
end
