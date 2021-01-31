local component = require("component")
local s = require("sides")
local vat = {
    {component.proxy("deecb33e-0a4a-4479-9182-ef2b7be20781"), component.proxy("2f8aec7c-7c7c-45b5-8903-166d2f2d7e5e")}, --mutagen
    {component.proxy("f64b2929-0fa6-4380-9655-aa98ceae9c18"), component.proxy("dcc67641-e8c0-462d-ab0e-a7cef74d99c2")}, --raw growth medium
    {component.proxy("35ee0c20-0df0-4ce5-b237-c09a542b39e4"), component.proxy("7d8b58e2-ce73-49ff-8cdd-f16612a49f7a")}, --raw bio medium
    {component.proxy("224be518-b96a-4edc-9fc3-a9242701a731"), component.proxy("28981b54-5c39-493d-a785-b90353ff817e")}, --seaweed broth
    {component.proxy("d00f10aa-76ea-40ac-94cd-8902f07a059c"), component.proxy("6ae3c9bd-8a4c-46cd-9961-5f1d1a4660eb")} --etc
}
while true do
    for i = 1, #vat do
        local active = vat[i][1].isMachineActive()
        local allowed = vat[i][1].isWorkAllowed()

        if active and allowed then
            vat[i][1].setWorkAllowed(false)
        end
        if (not active) and (not allowed) then
            local tank  = (vat[i][2].getFluidInTank(s.bottom))[1]
            if tank.amount < tank.capacity then
                local hatch = (vat[i][2].getFluidInTank(s.top))[1] 
                local cap = hatch.capacity * 0.48
                if hatch.amount > cap then
                    vat[i][2].transferFluid(s.top, s.bottom, hatch.amount - cap)
                end
                if hatch.amount <= cap then
                    if vat[i][2].getStackInSlot(s.west, 1) then
                        if vat[i][2].getStackInSlot(s.west, 1).size == 64 then
                            if i == 2 then
                                vat[i][2].transferItem(s.west, s.east, 4)
                            elseif i == 3 then
                                vat[i][2].transferItem(s.west, s.east, 13)
                            end
                            vat[i][1].setWorkAllowed(true)
                        end
                    else   
                        vat[i][1].setWorkAllowed(true)
                    end
                end
            end
        end
    end
    os.sleep(1)
end