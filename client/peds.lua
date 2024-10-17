--[[ this is an example if you want to use it you have to delete this line and the last line

exports['rip_dialog']:CreateNPC("testnpc2", "player_zero", vector4(2768.531, 1391.26, 24.52, 82.20), {
	label = "Talk",
	icon = "fas fa-user",
	title = "Title Name",
	content = "Hey! What are you looking for?",
	invisible = false,
	distance = 4.0,
	blip = {}
}, {
	options = {
		{
			icon = "fas fa-angle-right",
			label = "First option text, that uses img url",
			image = "https://www.w3schools.com/html/pic_trulli.jpg",
			params = {
				type = "action",
				event = function()
					print('This was called by the first option')
				end,
				args = {}
			}
		},
		{
			icon = "fas fa-angle-right",
			label = "Second option text, that uses img path",
			image = "/html/images/testgifimg.gif",
			params = {
				type = "server",
				event = "server:testoption",
				args = {
					message = "This was called by the second option"
				}
			}
		},
		{
			icon = "fas fa-angle-right",
			label = "Third option text",
			params = {
				type = "client",
				event = "client:testoption",
				args = {
					message = "This was called by clicking this button"
				}
			}
		},
		{
			icon = "fas fa-angle-right",
			label = "Fourth option text, that opens new menu options",
			params = {
				type = "action",
				event = function()
					exports['rip_dialog']:openMenu({
						title = "Title Name",
						content = "What did you have in mind?"
					}, {
						options = {
							{
								icon = "fas fa-angle-right",
								label = "menu option label",
								params = {
									type = "client",
									event = "client:testButton",
									args = {}
								}
							},
						},
					})
				end,
				args = {}
			}
		},
	},
})

delete this line]]