--[[

    Alert class
    This class is used to create an alert that will display a message on the screen.
    It will animate in and out of the screen.
    It will also play a sound when it appears.

    @version 1.0

    Copyright (C) 2024 Meowcino, licensed under MIT.
    Permission is hereby granted, free of charge, to any person obtaining a copy 
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation 
    the rights to use, copy, modify, merge, publish, distribute, sublicense, 
    and/or sell copies of the Software, and to permit persons to whom the Software 
    is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all 
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
    PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]--

local pd<const> = playdate
local gfx<const> = pd.graphics
local Animator<const> = pd.graphics.animator

-- We're extending the gfx.sprite class to create our Alert class.
class("Alert").extends(gfx.sprite)

-- This manually defines what notes to play using Playdate's synth and sequences.
function Alert:defineSfx()
    local synth = pd.sound.synth.new(pd.sound.kWaveSine)
    synth:setADSR(0.005, 0.1, 0.5, 0.1)
    synth:setVolume(1)
    local track = pd.sound.track.new()
    
    -- Add notes to the track
    track:addNote(2, "C4", 2)
    track:addNote(3, "A4", 1)
    track:addNote(4, "B4", 1)
    track:setInstrument(synth)

    -- Create a sequence and add the track
    self.sequence = pd.sound.sequence.new()
    self.sequence:setTempo(12)
    self.sequence:addTrack(track)
end


function Alert:init()
    Alert.super.init(self)
    -- Set alert positioning
    self:setCenter(0, 1) -- bottom left origin
    self:moveTo(0, 0)
    self:setZIndex(100) -- top layer
    -- Set black background image.
    self.image = gfx.image.new(400, 24, gfx.kColorBlack)
    self:setImage(self.image)
    self:defineSfx()
end

function Alert:animateInAlert()
    -- Setup and create the animator.
    local startY, endY = 0, 24
    local animTime = 250
    -- Set flag for animator checker so that we know the state.
    self.alertStateShowing = true
    self.anim = Animator.new(animTime, startY, endY, pd.easingFunctions.outCubic)
end

function Alert:animateOutAlert()
    -- Setup and create the animator.
    local startY, endY = 24, 0
    local animTime = 250
    self.alertStateShowing = false
    self.anim = Animator.new(animTime, startY, endY, pd.easingFunctions.inCubic, 3000)
end

function Alert:checkAnimator()
    if self.anim:ended() then
        -- Clear the animator.
        self.anim = nil
        if self.alertStateShowing then
            self:animateOutAlert()
        end
    else
        -- Update the sprite position.
        self:moveTo(0, self.anim:currentValue())
    end
end

function Alert:drawAlert(type, message)
    -- Draw the text and icon on the image.
    -- Context allows you to work within images: https://sdk.play.date/2.5.0/#_contexts
    gfx.pushContext(self.image)
        gfx.clear(gfx.kColorBlack)
        -- This will invert the color of the text as it's drawn onto the alert background.
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        -- Determine text offset
        local textOffset = 2
        gfx.drawText(message, textOffset, 1)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()
    self.sequence:play()
    self:animateInAlert()
    self:add()
end

-- Update function
function Alert:update()
    Alert.super.update(self)
    if self.anim then
        self:checkAnimator()
    end
end
