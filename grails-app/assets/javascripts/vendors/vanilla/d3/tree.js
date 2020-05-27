/***************************************************************
 *
 *  Copyright (C) 2016 Swayvil <swayvil@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  The GNU General Public License can be found at
 *  http://www.gnu.org/copyleft/gpl.html.
 *
 *  This script is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 ***************************************************************/

/*
 * Dependencies:
 * - d3.js
 * - jquery.js
 */
"use strict";

function treeBoxes(jsonData) {

    var blue = '#337ab7',
        green = '#5cb85c',
        yellow = '#f0ad4e',
        blueText = '#4ab1eb',
        purple = '#9467bd';

    var margin = {
            top: 0,
            right: 0,
            bottom: 100,
            left: 0
        },
        // Height and width are redefined later in function of the size of the tree
        // (after that the data are loaded)
        width = 800 - margin.right - margin.left,
        height = 400 - margin.top - margin.bottom;

    var rectNode = {width: 120, height: 45, textMargin: 5};
    var i = 0,
        duration = 750,
        root;

    var mousedown; // Use to save temporarily 'mousedown.zoom' value
    var mouseWheel,
        mouseWheelName,
        isKeydownZoom = false;

    var tree;
    var baseSvg,
        svgGroup,
        nodeGroup,
        linkGroup,
        defs;

    init(jsonData);

    function init(jsonData) {
        drawTree(jsonData);
    }

    function drawTree(jsonData) {
        tree = d3.layout.tree().size([height, width]);
        root = jsonData;
        root.fixed = true;

        // Dynamically set the height of the main svg container
        // breadthFirstTraversal returns the max number of node on a same level
        // and colors the nodes
        var maxDepth = 0;
        var maxTreeWidth = breadthFirstTraversal(tree.nodes(root), function(currentLevel) {
            maxDepth++;
        });
        height = maxTreeWidth * (rectNode.height + 20) + 20 - margin.right - margin.left;
        width = maxDepth * (rectNode.width * 1.5) - margin.top - margin.bottom;

        tree = d3.layout.tree().size([height, width]);
        root.x0 = height / 2;
        root.y0 = 0;

        baseSvg = d3.select('#tree-container').append('svg')
            .attr('width', width + margin.right + margin.left)
            .attr('height', height + margin.top + margin.bottom)
            .attr('class', 'svgContainer')
            .call(d3.behavior.zoom()
                //.scaleExtent([0.5, 1.5]) // Limit the zoom scale
                .on('zoom', zoomAndDrag));

        // Mouse wheel is desactivated, else after a first drag of the tree, wheel event drags the tree (instead of scrolling the window)
        getMouseWheelEvent();
        d3.select('#tree-container').select('svg').on(mouseWheelName, null);
        d3.select('#tree-container').select('svg').on('dblclick.zoom', null);

        svgGroup = baseSvg.append('g')
            .attr('class', 'drawarea')
            .append('g')
            .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

        nodeGroup = svgGroup.append('g')
            .attr('id', 'nodes');
        linkGroup = svgGroup.append('g')
            .attr('id', 'links');

        defs = baseSvg.append('defs');
        update(root);
    }

    function update(source) {
        // Compute the new tree layout
        var nodes = tree.nodes(root).reverse(),
            links = tree.links(nodes);

        // Check if two nodes are in collision on the ordinates axe and move them
        breadthFirstTraversal(tree.nodes(root), collision);
        // Normalize for fixed-depth
        nodes.forEach(function(d) {
            d.y = d.depth * (rectNode.width * 1.5);
        });

        // 1) ******************* Update the nodes *******************
        var node = nodeGroup.selectAll('g.node').data(nodes, function(d) {
            return d.id || (d.id = ++i);
        });

        var nodeEnter = node.enter().insert('g', 'g.node')
            .attr('class', 'node')
            .attr('transform', function(d) {
                return 'translate(' + source.y0 + ',' + source.x0 + ')';
            })
            .on('click', function(d) {
                click(d);
            });

        nodeEnter.append('g').append('rect')
            .attr('rx', 6)
            .attr('ry', 6)
            .attr('width', rectNode.width)
            .attr('height', rectNode.height)
            .attr('class', 'node-rect')
            .attr('fill', function(d) { return d.color; })
            .attr('filter', 'url(#drop-shadow)');

        nodeEnter.append('foreignObject')
            .attr('x', rectNode.textMargin)
            .attr('y', rectNode.textMargin)
            .attr('width', function() {
                return (rectNode.width - rectNode.textMargin * 2) < 0 ? 0
                                                                      : (rectNode.width - rectNode.textMargin * 2)
            })
            .attr('height', function() {
                return (rectNode.height - rectNode.textMargin * 2) < 0 ? 0
                                                                       : (rectNode.height - rectNode.textMargin * 2)
            })
            .append('xhtml').html(function(d) {
            return 'toto';
        });

        // Transition nodes to their new position.
        var nodeUpdate = node.transition().duration(duration)
            .attr('transform', function(d) { return 'translate(' + d.y + ',' + d.x + ')'; });

        nodeUpdate.select('rect')
            .attr('class', function(d) { return d._children ? 'node-rect-closed' : 'node-rect'; });

        nodeUpdate.select('text').style('fill-opacity', 1);

        // Transition exiting nodes to the parent's new position
        var nodeExit = node.exit().transition().duration(duration)
            .attr('transform', function(d) { return 'translate(' + source.y + ',' + source.x + ')'; })
            .remove();

        nodeExit.select('text').style('fill-opacity', 1e-6);


        // 2) ******************* Update the links *******************
        var link = linkGroup.selectAll('path').data(links, function(d) {
            return d.target.id;
        });

        // Enter any new links at the parent's previous position.
        // Enter any new links at the parent's previous position.
        var linkenter = link.enter().insert('path', 'g')
            .attr('class', 'link')
            .attr('id', function(d) { return 'linkID' + d.target.id; })
            .attr('d', function(d) { return diagonal(d); });

        // Transition links to their new position.
        var linkUpdate = link.transition().duration(duration)
            .attr('d', function(d) { return diagonal(d); });

        // Transition exiting nodes to the parent's new position.
        link.exit().transition()
            .remove();

        // Stash the old positions for transition.
        nodes.forEach(function(d) {
            d.x0 = d.x;
            d.y0 = d.y;
        });
    }

    // Zoom functionnality is desactivated (user can use browser Ctrl + mouse wheel shortcut)
    function zoomAndDrag() {
        //var scale = d3.event.scale,
        var scale = 1,
            translation = d3.event.translate,
            tbound = -height * scale,
            bbound = height * scale,
            lbound = (-width + margin.right) * scale,
            rbound = (width - margin.left) * scale;
        // limit translation to thresholds
        translation = [
            Math.max(Math.min(translation[0], rbound), lbound),
            Math.max(Math.min(translation[1], bbound), tbound)
        ];
        d3.select('.drawarea')
            .attr('transform', 'translate(' + translation + ')' +
                               ' scale(' + scale + ')');
    }

    // Toggle children on click.
    function click(d) {
        if (d.children) {
            d._children = d.children;
            d.children = null;
        } else {
            d.children = d._children;
            d._children = null;
        }
        update(d);
    }

    // Breadth-first traversal of the tree
    // func function is processed on every node of a same level
    // return the max level
    function breadthFirstTraversal(tree, func) {
        var max = 0;
        if (tree && tree.length > 0) {
            var currentDepth = tree[0].depth;
            var fifo = [];
            var currentLevel = [];

            fifo.push(tree[0]);
            while (fifo.length > 0) {
                var node = fifo.shift();
                if (node.depth > currentDepth) {
                    func(currentLevel);
                    currentDepth++;
                    max = Math.max(max, currentLevel.length);
                    currentLevel = [];
                }
                currentLevel.push(node);
                if (node.children) {
                    for (var j = 0; j < node.children.length; j++) {
                        fifo.push(node.children[j]);
                    }
                }
            }
            func(currentLevel);
            return Math.max(max, currentLevel.length);
        }
        return 0;
    }

    // x = ordoninates and y = abscissas
    function collision(siblings) {
        var minPadding = 5;
        if (siblings) {
            for (var i = 0; i < siblings.length - 1; i++) {
                if (siblings[i + 1].x - (siblings[i].x + rectNode.height) < minPadding) {
                    siblings[i + 1].x = siblings[i].x + rectNode.height + minPadding;
                }
            }
        }
    }

    // Name of the event depends of the browser
    function getMouseWheelEvent() {
        if (d3.select('#tree-container').select('svg').on('wheel.zoom')) {
            mouseWheelName = 'wheel.zoom';
            return d3.select('#tree-container').select('svg').on('wheel.zoom');
        }
        if (d3.select('#tree-container').select('svg').on('mousewheel.zoom') != null) {
            mouseWheelName = 'mousewheel.zoom';
            return d3.select('#tree-container').select('svg').on('mousewheel.zoom');
        }
        if (d3.select('#tree-container').select('svg').on('DOMMouseScroll.zoom')) {
            mouseWheelName = 'DOMMouseScroll.zoom';
            return d3.select('#tree-container').select('svg').on('DOMMouseScroll.zoom');
        }
    }

    function diagonal(d) {
        var p0 = {
            x: d.source.x + rectNode.height / 2,
            y: (d.source.y + rectNode.width)
        }, p3 = {
            x: d.target.x + rectNode.height / 2,
            y: d.target.y
        }, m = (p0.y + p3.y) / 2, p = [p0, {
            x: p0.x,
            y: m
        }, {
            x: p3.x,
            y: m
        }, p3];
        p = p.map(function(d) {
            return [d.y, d.x];
        });
        return 'M' + p[0] + 'C' + p[1] + ' ' + p[2] + ' ' + p[3];
    }
}