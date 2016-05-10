#ifndef TOON_RAMP_BRDF_INCLUDED
#define TOON_RAMP_BRDF_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityStandardBRDF.cginc"

uniform sampler1D _ToonRamp;

half4 ToonRamp_BRDF(
	half3 diffColor,
	half3 specColor,
	half oneMinusReflectivity,
	half oneMinusRoughness,
	half3 normal,
	half3 viewDir,
	UnityLight light,
	UnityIndirect gi)
{
	half3 halfDir = Unity_SafeNormalize(light.dir + viewDir);

	half nl = light.ndotl;
	half nh = BlinnTerm(normal, halfDir);
	half nv = DotClamped(normal, viewDir);
	half lh = DotClamped(light.dir, halfDir);

	half roughness = 1 - oneMinusRoughness;
	half specularPower = RoughnessToSpecPower(roughness);
	half invV = lh * lh * oneMinusRoughness + roughness * roughness; // approx ModifiedKelemenVisibilityTerm(lh, 1-oneMinusRoughness);
	half invF = lh;
	half specular = ((specularPower + 1) * pow(nh, specularPower)) / (8 * invV * invF + 1e-4h);

	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)
	half realRoughness = roughness*roughness;		// need to square perceptual roughness
	// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
	// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
	half surfaceReduction = 0.6 - 0.08*roughness;
	surfaceReduction = 1.0 - realRoughness*roughness*surfaceReduction;
	half grazingTerm = saturate(oneMinusRoughness + (1 - oneMinusReflectivity));

	half halfLambert = nl * 0.5f + 0.5f;
	halfLambert *= halfLambert;

	half3 toonColor = tex1D(_ToonRamp, halfLambert);

	//half3 lightingColor = ;

	//half3 lightingColor = lerp(toonColor, light.color, length(light.color));


	/*half3 color =   (diffColor + specular * specColor) * light.color * nl
					+ gi.diffuse * diffColor
					+ surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);
	*/

	//half temp =  * specColor;
	//return half4(temp, temp, temp, 1);
	//return half4(toonColor, 1);


	half3 diffuseColor = diffColor * toonColor * light.color;
	half3 specularColor = step(0.3, specular) * specColor;
	half3 globalDiffuse = gi.diffuse * diffColor;
	half3 globalSpec = surfaceReduction * gi.specular * FresnelLerpFast(specColor, grazingTerm, nv);


	half3 color =
		diffuseColor
		+ specularColor
		+ globalDiffuse
		+ globalSpec;


	//return half4(oneMinusRoughness, oneMinusReflectivity, 0, 1);
	return half4(color, 1);
}


#endif // TOON_RAMP_BRDF_INCLUDED
