Jobs.RegisterMenu('safe_items', function(isPrimaryJob)
    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'safe_menu',
        {
            title       = 'test',
            align       = 'top-left',
            elements    = {
                { label = 'ADD', value = 'add_items' },
                { label = 'REMOVE', value = 'remove_items' },
            },
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
        end,
        function(data, menu)
            menu.close()
        end)
end)