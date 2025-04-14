//// SEQUENCER_GUI CONSTRUCTOR
(
~buildWindow = {
	// Builds the main window that contains everything
	arg window_title, x=10, y=10, width, height;
	Window(window_title, Rect(x, y, width, height))
	.background_(~style_1.at("window_color"))
	.front;
};

~buildTopLevel = {
	// Buildts a top level composite view that manages child views' spacing.
	arg window, posx=10, posy=10, width, height;
	var compView = CompositeView(window, Rect(posx, posy, width, height))
	.background_(~style_1["top_level_frame_color"]);
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(0@10);
	//"built toplevel".postln;
	compView;
};

~buildSequencerHeader = {
	// Builds a header frame with a static text box with the title of the window
	arg top, hwidth, hheight, string;
	var guiTitle;
	guiTitle = StaticText(top, Rect(10, 10, hwidth, hheight));
	guiTitle.string = string;
	guiTitle.background = ~style_1["top_level_frame_color"];
	guiTitle.font = ~style_1.at("header_font");
	guiTitle.align = \center;
	top.decorator.nextLine;
	//"built header".postln;
	guiTitle;
};

~buildCategoryLabels = {
	// Builds a frame to contain the labels of the button rows
	arg top_level, width, height, buttonsize, offset;
	var array ;
	var compView = CompositeView(top_level, Rect(0, 0, width, height))
	.background_(~style_1.at("top_level_frame_color"));
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);

	StaticText(compView, Rect(10, 10, width, buttonsize+10))
	.string_("")
	.background_(~style_1["bank_frame_color"])
	.font_(~style_1.at("header_font"))
	.align_(\center);
	compView.decorator.nextLine;
	array = Array.fill(5, {arg i;
		StaticText(compView, Rect(10+(i*buttonsize)+20, 10, width, buttonsize))
		.string_(~categories.at(i))
		.background_(~style_1["bank_frame_color"])
		.font_(~style_1.at("subheader_font"))
		.align_(\right);
	});
	compView.decorator.nextLine;
	StaticText(compView, Rect(10, 10, width, buttonsize+10))
	.string_("")
	.background_(~style_1["bank_frame_color"])
	.font_(~style_1.at("header_font"))
	.align_(\center);
	compView.decorator.nextLine;
	compView;
};

~buildTrackButtonsContainer = {
	// Builds a frame to contain and organize the track and the stack of buttons.
	arg top_level, width, height;
	var compView = CompositeView(top_level, Rect(0, 0, width, height))
	.background_(~style_1.at("top_level_frame_color"));
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);
	compView;
};

~buildSequencerTrack = {
	// Builds the sequencer track.
	arg top, columns, buttonsize;
	var trackCompView, array, sequencer_track_data, buttonColor;

	// Track Composite View
	trackCompView = CompositeView(top, Rect(0, 0, buttonsize*columns+20, buttonsize));
	trackCompView.background = ~style_1.at("bank_frame_color");

	// Sequencer Track: A set of static texts that change colors when the pattern
	// scrolls over it.
	array = Array.fill(columns, { arg i;
		if (floor(i/4).asInteger.even) {
			buttonColor = Color.white;
		} {
			buttonColor = ~style_1["lightgrey"];
		};
		StaticText(trackCompView, Rect(i * buttonsize + 10, 10, buttonsize, buttonsize/2))
		.background_(buttonColor);
	});
	top.decorator.nextLine;
	sequencer_track_data = [trackCompView, array]
};

~buildRotaryFader = {
	|top, posx, posy, offset, size, constants, mins, maxes|
	var knobs, knobView, constant, knobData, newValues;
	knobView = CompositeView(top, Rect(posx, posy, size*4, size*3))
	.background_(~style_1.at("bank_frame_color"));
	knobs = Array.fill(3, {|i|
		Knob(knobView, Rect(0, offset * i, size, size))
		.background_(~style_1["lightgrey"])
		.visible_(true)
		.enabled_(true)
		.action_({|v|
			currentEnvironment.put(constants[i], v.value.lincurve(0.0, 1.0, mins[i], maxes[i]));
			newValues[i].string = constants[i] ++ " : " ++ v.value.lincurve(0.0, 1.0, mins[i], maxes[i]).trunc(0.001);
		});
	});
	newValues = Array.fill(3, {|i|
        StaticText(knobView, Rect(offset, size * i, size, size))
		.string_(constants[i] ++ " : " ++ currentEnvironment.at(constants[i]))
		.background_(~style_1.at("bank_frame_color"))
		.font_(~style_1.at("text_font"))
		.align_(\center)
	});
    knobView.layout_(HLayout(VLayout(*knobs), VLayout(*newValues)));
};

~buildSequencerButtons = {
	// Builds n stacks of columns * rows buttons that control different sequencer levels.
	arg top_level, width, height, buttonsize, offset, rows, columns;
	var butCompView, array, buttonsData;

	// Builds an array of sequencer buttons (themselves a 2DArray).
	butCompView = CompositeView(top_level, Rect(0, 0, width, height)).background_(~style_1.at("bank_frame_color"));

	// Sequencer Buttons
	array = 0!columns!rows;
	array.do{ |rows, i|
		rows.do{ |cell, j|
			Button(butCompView, Rect(j*buttonsize+offset, i*buttonsize+offset, buttonsize, buttonsize))
			.states_([
				["", ~style_1.at("text_color"), Color.white],
				["", Color.white, ~style_1.at("text_color")],
			])
			.action_{ |v|
				array[i][j] = v.value;
			};
		};
	};

	top_level.decorator.nextLine;
	buttonsData = [butCompView, array];
};

~buildSliderButtons = {
	// build the views for the soundfiles and the range sliders
	arg top_level, sliderwidth, button_field_height, buttonsize, offset, rows;
	var filler, compView, sliderAndFileViews, slider_button_data, rel_height=0.6;
	compView = CompositeView(top_level, Rect(0, 0, sliderwidth+offset, buttonsize+(2*offset)+button_field_height))
	.background_(~style_1.at("bank_frame_color"));
	filler = CompositeView(compView, Rect(0, 0, sliderwidth+offset, buttonsize+offset))
		.background_(~style_1.at("bank_frame_color"));

	sliderAndFileViews=Dictionary.new;
	~categories.do({arg cat, i;
		var buffer_info = ~uttSamples[~categories[i]];
		var numFrames = buffer_info[0].numFrames;
		sliderAndFileViews[cat] = [
			SoundFileView(compView, Rect(0, buttonsize+offset+(i*buttonsize), sliderwidth, buttonsize*rel_height))
			.readFile(SoundFile.openRead(buffer_info[0].path), 0, numFrames)
			.drawsRMS_(false)
			.yZoom_(2),
			RangeSlider(compView, Rect(0, buttonsize*(1+rel_height)+offset+(i*buttonsize), sliderwidth, buttonsize*(1-rel_height)))
			.action_({ |slider|
				buffer_info[1] = (slider.lo.lincurve(0, 1, 0 , numFrames, 0)).asInteger;
				buffer_info[2] = (slider.hi.lincurve(0, 1, 0 , numFrames, 0)).asInteger;
			})
			.background_(Color.white)
		]
	});

	slider_button_data = [compView, sliderAndFileViews];
};

~buildUtteranceSelectors = {
	arg top_level, selector_width, button_field_height, buttonsize, offset, rows;
	var selectorData, compView, selectors;
	compView = CompositeView(top_level, Rect(0, 0, selector_width+offset, buttonsize+(2*offset) + button_field_height))
	.background_(~style_1.at("bank_frame_color"));
	selectors = Dictionary.new;
	~categories.do({arg cat, i;
		selectors[cat] = PopUpMenu(compView, Rect(0, buttonsize+offset+(i*buttonsize), selector_width, buttonsize))
		.items_([cat])
		.action_({arg pm; ~selectorAction.(pm);})
		.name_(cat);
	});
	selectorData = [compView, selectors];
};

~update_track_seq = {
	// Updates the track, giving one of the StaticText objects a random color and turning
	// off the previous index.
	arg index, track;
	var buttonColor = Color.white;
	// Determine button background based on position in track
	if (floor((index-1)/4).asInteger.odd) {
		buttonColor = ~style_1["lightgrey"];
	};
	{ track[1][index].background_(Color.rand).string_(index.asString) }.defer;
	if((index == 0), {
		{ track[1][track[1].size-1].background_(buttonColor).string_("") }.defer;
	}, {
		{ track[1][index-1].background_(buttonColor).string_("") }.defer;
	});
};


//// MC_GUI CONSTRUCTOR

~buildMcTrack = {
	// Builds the MC Track
	arg top, posx, posy, hwidth, hheight, columns, buttonsize;
	var trackCompView, fields, values, sequencer_track_data;

	// Track Composite View
	trackCompView = CompositeView(top, Rect(posx, posy, buttonsize*columns+20, hheight-20))
	.background_(Color.white);

	// Sequencer Track: A set of static texts for labels
	// plus StaticTExt that change text values
	// scrolls over it.
	fields = Array.fill(columns, { arg i;
		StaticText(trackCompView, Rect(i * buttonsize, posy, buttonsize,hheight/10))
		.background_(~style_1[~categories[i].asString])
		.string_("value: \n%".format(~volMin))
		.align_(\bottom);
	});

	top.decorator.nextLine;
	sequencer_track_data = [trackCompView, fields]
};


~buildStatus = {
	// Builds the status area
	arg top, posx, posy, fWidth, fHeight, utterances;
	var compView, state, utts, state_data;
	// Track Composite View
	compView = CompositeView(top, Rect(posx, posy, fWidth + 30, fHeight +30))
	.background_(Color.white);
	state = StaticText(compView, Rect(5, 5 , fWidth, fHeight))
	.background_(~style_1["bank_frame_color"])
	.font_(~style_1.at("subheader_font"))
	.string_("state: 00")
	.align_(\bottomLeft);
	compView.addFlowLayout(5@0);
	compView.decorator.gap_(0@5);
	utts = Array.fill(3, { arg i;
		StaticText(compView, Rect(5, 20 * i, fWidth, fHeight/6))
		.background_(~style_1["header_frame_color"])
		.font_(~style_1.at("text_font"))
		.string_(utterances[i])
		.align_(\topLeft);
	});
	//top.decorator.nextLine;
	state_data = [compView, state, utts]
};


~buildMcLabels = {
	// Builds a frame to contain the labels of the button rows
	arg top_level, posx, posy, width, height, buttonsize, uttdict;
	var array, compView, labels, counts, label_data;
	//"pos x %   pos y %".format(posx, posy).postln;
	labels = ~categories ++ ["total"];
	counts = uttdict.values ++ [0];
	compView = CompositeView(top_level, Rect(posx, posy, width, height))
	.background_(Color.white);
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);
	array = Array.fill(6, {arg i;
		StaticText(compView, Rect(posx, posy, width/6, height))
		.string_(labels.at(i) ++ "\n" ++ counts[i])
		.background_(~style_1[labels[i].asString])
		.font_(~style_1.at("subheader_font"))
		.align_(\top);
	});
	compView.decorator.nextLine;
	label_data = [compView, array]
};

)