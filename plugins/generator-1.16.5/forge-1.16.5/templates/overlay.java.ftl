<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2020 Pylo and contributors
 # 
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # 
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 # 
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 # 
 # Additional permission for code generator templates (*.ftl files)
 # 
 # As a special exception, you may create a larger work that contains part or 
 # all of the MCreator code generator templates (*.ftl files) and distribute 
 # that work under terms of your choice, so long as that work isn't itself a 
 # template for code generation. Alternatively, if you modify or redistribute 
 # the template itself, you may (at your option) remove this special exception, 
 # which will cause the template and the resulting code generator output files 
 # to be licensed under the GNU General Public License without this special 
 # exception.
-->

<#-- @formatter:off -->
<#include "tokens.ftl">
<#include "procedures.java.ftl">

<#assign hasTextures = data.baseTexture?has_content>
<#list data.components as component>
	<#if component.getClass().getSimpleName() == "Image">
		<#assign hasTextures = true>
		<#break>
	</#if>
</#list>

package ${package}.gui.overlay;

@Mod.EventBusSubscriber public class ${name}Overlay {

	@OnlyIn(Dist.CLIENT)
	@SubscribeEvent(priority = EventPriority.${data.priority})
	<#if generator.map(data.overlayTarget, "screens") == "Ingame">
	public static void eventHandler(RenderGameOverlayEvent.Post event) {
		if (event.getType() == RenderGameOverlayEvent.ElementType.HELMET) {
			int w = event.getWindow().getScaledWidth();
			int h = event.getWindow().getScaledHeight();
	<#else>
	public static void eventHandler(GuiScreenEvent.DrawScreenEvent.Post event) {
		if (event.getGui() instanceof ${generator.map(data.overlayTarget, "screens")}) {
			int w = event.getGui().width;
			int h = event.getGui().height;
	</#if>
			World _world = null;
			double _x = 0;
			double _y = 0;
			double _z = 0;

			PlayerEntity entity = Minecraft.getInstance().player;
			if (entity != null) {
				_world = entity.world;
				_x = entity.getPosX();
				_y = entity.getPosY();
				_z = entity.getPosZ();
			}

			World world = _world;
			double x = _x;
			double y = _y;
			double z = _z;

			<#if hasTextures>
				RenderSystem.disableDepthTest();
				RenderSystem.depthMask(false);
				RenderSystem.blendFuncSeparate(GlStateManager.SourceFactor.SRC_ALPHA, GlStateManager.DestFactor.ONE_MINUS_SRC_ALPHA,
						GlStateManager.SourceFactor.ONE, GlStateManager.DestFactor.ZERO);
				RenderSystem.color4f(1.0F, 1.0F, 1.0F, 1.0F);
				RenderSystem.disableAlphaTest();
			</#if>

			if (<@procedureOBJToConditionCode data.displayCondition/>) {
				<#if data.baseTexture?has_content>
					Minecraft.getInstance().getTextureManager().bindTexture(new ResourceLocation("${modid}:textures/screens/${data.baseTexture}"));
					Minecraft.getInstance().ingameGUI.blit(event.getMatrixStack(), 0, 0, 0, 0, w, h, w, h);
				</#if>

				<#list data.components as component>
	                <#assign x = component.x>
	                <#assign y = component.y>
	                <#if component.getClass().getSimpleName() == "Label">
						<#if hasProcedure(component.displayCondition)>
						if (<@procedureOBJToConditionCode component.displayCondition/>)
						</#if>
						<#if component.enableTK>
							Minecraft.getInstance().fontRenderer.drawString(event.getMatrixStack(), new TranslatableComponent("${component.TK}"),
                        									${x / 426} * w , ${y / 240 } * h , ${component.color.getRGB()});
						<#else>
						Minecraft.getInstance().fontRenderer.drawString(event.getMatrixStack(), "${translateTokens(JavaConventions.escapeStringForJava(component.TK))}",
									${x / 426 } * w , ${y / 240} * h , ${component.color.getRGB()});
						</#if>
	                <#elseif component.getClass().getSimpleName() == "Image">
						<#if hasProcedure(component.displayCondition)>
						if (<@procedureOBJToConditionCode component.displayCondition/>) {
						</#if>
						Minecraft.getInstance().getTextureManager().bindTexture(new ResourceLocation("${modid}:textures/screens/${component.image}"));
						Minecraft.getInstance().ingameGUI.blit(event.getMatrixStack(), ${x / 426 } * w , ${y / 240} * h , 0, 0,
							${component.getWidth(w.getWorkspace())}, ${component.getHeight(w.getWorkspace())},
							${component.getWidth(w.getWorkspace())}, ${component.getHeight(w.getWorkspace())});

						<#if hasProcedure(component.displayCondition)>}</#if>
	                </#if>
	            </#list>
			}

			<#if hasTextures>
				RenderSystem.depthMask(true);
				RenderSystem.enableDepthTest();
				RenderSystem.enableAlphaTest();
				RenderSystem.color4f(1.0F, 1.0F, 1.0F, 1.0F);
			</#if>
		}
	}

}
<#-- @formatter:on -->